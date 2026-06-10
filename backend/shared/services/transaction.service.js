import mongoose from "mongoose";

export class TransactionService {
  async run(work, options = {}) {
    const session = await mongoose.startSession();

    try {
      let result;
      await session.withTransaction(async () => {
        result = await work(session);
      }, options);
      return result;
    } finally {
      await session.endSession();
    }
  }
}

export const transactionService = new TransactionService();
