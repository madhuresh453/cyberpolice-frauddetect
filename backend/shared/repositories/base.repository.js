export class BaseRepository {
  constructor(model) {
    this.model = model;
  }

  async create(data, options = {}) {
    const [document] = await this.model.create([data], options);
    return document;
  }

  async update(filter, updates, options = {}) {
    return this.model.findOneAndUpdate(filter, updates, {
      new: true,
      runValidators: true,
      ...options
    });
  }

  async delete(filter, context = {}) {
    return this.model.findOneAndUpdate(
      filter,
      {
        deletedAt: new Date(),
        deletedBy: context.deletedBy || null
      },
      { new: true, runValidators: true }
    );
  }

  async findOne(filter, options = {}) {
    return this.model.findOne(filter, null, options);
  }

  async findMany(filter = {}, options = {}) {
    const query = this.model.find(filter, null, options);
    if (options.sort) query.sort(options.sort);
    if (options.limit) query.limit(options.limit);
    if (options.skip) query.skip(options.skip);
    if (options.populate) query.populate(options.populate);
    return query.exec();
  }

  async paginate(filter = {}, options = {}) {
    const page = Math.max(Number.parseInt(options.page || "1", 10), 1);
    const limit = Math.min(Math.max(Number.parseInt(options.limit || "25", 10), 1), 100);
    const skip = (page - 1) * limit;
    const sort = options.sort || { createdAt: -1 };

    const [items, total] = await Promise.all([
      this.model.find(filter).sort(sort).skip(skip).limit(limit).exec(),
      this.model.countDocuments(filter)
    ]);

    return {
      items,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  async aggregate(pipeline = [], options = {}) {
    return this.model.aggregate(pipeline).option(options).exec();
  }
}
