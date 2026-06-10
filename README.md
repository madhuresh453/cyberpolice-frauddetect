# CYBERSHIELD AI

This workspace contains the CYBERSHIELD AI scaffold plus a production-ready MongoDB Atlas backend foundation.

- [CYBERSHIELD_AI_COMPLETE_CODEX_PROMPT.md](./CYBERSHIELD_AI_COMPLETE_CODEX_PROMPT.md)
- [docs/MONGODB_ATLAS_SETUP.md](./docs/MONGODB_ATLAS_SETUP.md)

MongoDB Atlas is the only active database for this codebase. Do not add PostgreSQL, MySQL, SQLite, Supabase, Prisma SQL, or another relational database layer.

## Backend Quick Start

```powershell
npm install
Copy-Item .env.example .env
# edit .env and set MONGODB_URI and JWT_SECRET
npm run db:verify
npm run seed
npm run dev
```

Health endpoints:

- `GET http://localhost:5000/health`
- `GET http://localhost:5000/database/status`

## Notes

- Government integrations such as Sanchar Saathi, TRAI, and cybercrime.gov.in need official API access or approved manual fallback flows.
- Android call recording and WhatsApp monitoring require careful legal and platform review before implementation.
- Treat generated demo credentials, seed data, and integration stubs as local development material only.
