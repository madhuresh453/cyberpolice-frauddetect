import { models } from "../models/index.js";
import { BaseRepository } from "./base.repository.js";

export const repositories = Object.fromEntries(
  Object.entries(models).map(([name, model]) => [name, new BaseRepository(model)])
);

export { BaseRepository };
