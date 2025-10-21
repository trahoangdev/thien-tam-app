import { Schema, model } from "mongoose";

const UserSchema = new Schema({
  email: { type: String, unique: true, required: true, index: true },
  passwordHash: { type: String, required: true },
  roles: { type: [String], default: ["EDITOR"] }, // ["ADMIN"] có toàn quyền
  isActive: { type: Boolean, default: true },
}, { timestamps: true });

export default model("User", UserSchema);

