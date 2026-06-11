import Redis from "ioredis";

let redisClient = null;
let redisSubscriber = null;
let redisPublisher = null;

const REDIS_CONFIG = {
  host: process.env.REDIS_HOST || "127.0.0.1",
  port: Number.parseInt(process.env.REDIS_PORT || "6379", 10),
  password: process.env.REDIS_PASSWORD || undefined,
  db: Number.parseInt(process.env.REDIS_DB || "0", 10),
  maxRetriesPerRequest: 3,
  retryStrategy(times) {
    if (times > 3) return null;
    return Math.min(times * 200, 2000);
  },
  enableReadyCheck: true,
  lazyConnect: true
};

export async function connectRedis() {
  if (redisClient && redisClient.status === "ready") {
    return redisClient;
  }

  try {
    redisClient = new Redis(REDIS_CONFIG);
    await redisClient.connect();
    console.log(JSON.stringify({ level: "info", message: "Redis connected" }));
    return redisClient;
  } catch (error) {
    console.warn(JSON.stringify({ level: "warn", message: "Redis connection failed, using graceful fallback", error: error.message }));
    redisClient = createFallbackClient();
    return redisClient;
  }
}

export async function disconnectRedis() {
  if (redisClient) {
    await redisClient.quit();
    redisClient = null;
  }
  if (redisSubscriber) {
    await redisSubscriber.quit();
    redisSubscriber = null;
  }
  if (redisPublisher) {
    await redisPublisher.quit();
    redisPublisher = null;
  }
}

export function getRedisClient() {
  if (!redisClient) {
    redisClient = createFallbackClient();
  }
  return redisClient;
}

export function getRedisSubscriber() {
  if (!redisSubscriber) {
    redisSubscriber = createFallbackClient();
  }
  return redisSubscriber;
}

export function getRedisPublisher() {
  if (!redisPublisher) {
    redisPublisher = createFallbackClient();
  }
  return redisPublisher;
}

function createFallbackClient() {
  const store = new Map();
  const timers = new Map();

  const fallback = {
    status: "ready",
    store,
    async get(key) { return store.get(key) || null; },
    async set(key, value, ...args) {
      store.set(key, value);
      const exIndex = args.indexOf("EX");
      if (exIndex !== -1) {
        const ttl = Number.parseInt(args[exIndex + 1], 10) * 1000;
        if (timers.has(key)) clearTimeout(timers.get(key));
        timers.set(key, setTimeout(() => { store.delete(key); timers.delete(key); }, ttl));
      }
      return "OK";
    },
    async del(...keys) {
      let count = 0;
      for (const key of keys) {
        if (store.delete(key)) count++;
        if (timers.has(key)) { clearTimeout(timers.get(key)); timers.delete(key); }
      }
      return count;
    },
    async exists(key) { return store.has(key) ? 1 : 0; },
    async expire(key, seconds) {
      if (!store.has(key)) return 0;
      if (timers.has(key)) clearTimeout(timers.get(key));
      timers.set(key, setTimeout(() => { store.delete(key); timers.delete(key); }, seconds * 1000));
      return 1;
    },
    async ttl(key) { return store.has(key) ? -1 : -2; },
    async incr(key) { const val = (Number.parseInt(store.get(key) || "0", 10)) + 1; store.set(key, String(val)); return val; },
    async incrby(key, increment) { const val = (Number.parseInt(store.get(key) || "0", 10)) + increment; store.set(key, String(val)); return val; },
    async decr(key) { const val = (Number.parseInt(store.get(key) || "0", 10)) - 1; store.set(key, String(val)); return val; },
    async keys(pattern) {
      const regex = new RegExp("^" + pattern.replace(/\*/g, ".*").replace(/\?/g, ".") + "$");
      return [...store.keys()].filter(k => regex.test(k));
    },
    async mget(...keys) { return keys.map(k => store.get(k) || null); },
    async mset(...args) { for (let i = 0; i < args.length; i += 2) store.set(args[i], args[i + 1]); return "OK"; },
    async hset(key, ...args) {
      let obj = {};
      try { obj = JSON.parse(store.get(key) || "{}"); } catch { obj = {}; }
      for (let i = 0; i < args.length; i += 2) obj[args[i]] = args[i + 1];
      store.set(key, JSON.stringify(obj));
      return args.length / 2;
    },
    async hget(key, field) {
      try { const obj = JSON.parse(store.get(key) || "{}"); return obj[field] || null; } catch { return null; }
    },
    async hgetall(key) {
      try { return JSON.parse(store.get(key) || "{}"); } catch { return {}; }
    },
    async hdel(key, ...fields) {
      try {
        const obj = JSON.parse(store.get(key) || "{}");
        let count = 0;
        for (const f of fields) { if (f in obj) { delete obj[f]; count++; } }
        store.set(key, JSON.stringify(obj));
        return count;
      } catch { return 0; }
    },
    async lpush(key, ...values) {
      let arr = [];
      try { arr = JSON.parse(store.get(key) || "[]"); } catch { arr = []; }
      arr.unshift(...values);
      store.set(key, JSON.stringify(arr));
      return arr.length;
    },
    async rpush(key, ...values) {
      let arr = [];
      try { arr = JSON.parse(store.get(key) || "[]"); } catch { arr = []; }
      arr.push(...values);
      store.set(key, JSON.stringify(arr));
      return arr.length;
    },
    async lrange(key, start, stop) {
      try {
        const arr = JSON.parse(store.get(key) || "[]");
        if (stop === -1) stop = arr.length - 1;
        return arr.slice(start, stop + 1);
      } catch { return []; }
    },
    async sadd(key, ...members) {
      let set = new Set();
      try { set = new Set(JSON.parse(store.get(key) || "[]")); } catch { set = new Set(); }
      let count = 0;
      for (const m of members) { if (!set.has(m)) { set.add(m); count++; } }
      store.set(key, JSON.stringify([...set]));
      return count;
    },
    async sismember(key, member) {
      try { const set = new Set(JSON.parse(store.get(key) || "[]")); return set.has(member) ? 1 : 0; } catch { return 0; }
    },
    async smembers(key) {
      try { return JSON.parse(store.get(key) || "[]"); } catch { return []; }
    },
    async publish(channel, message) { return 0; },
    async subscribe() { },
    async quit() { for (const t of timers.values()) clearTimeout(t); timers.clear(); store.clear(); return "OK"; },
    on() { return fallback; }
  };

  return fallback;
}

export async function getRedisHealth() {
  try {
    const client = getRedisClient();
    const ping = await client.ping();
    return { connected: ping === "PONG" || ping === "OK", status: client.status };
  } catch {
    return { connected: false, status: "disconnected" };
  }
}