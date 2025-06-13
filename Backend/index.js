import express from "express";
import cors from "cors";
import mongoose from "mongoose";
import todoRouter from "./src/modules/todos/todo.router.js";

const app = express();
const PORT = 3000;

// Use CORS Middleware
app.use(cors("*"));

// Middleware to parse JSON data
app.use(express.json());

// MongoDB Connection URI
const DB_HOST = process.env.MONGO_HOST || "localhost";
const DB_PORT = process.env.MONGO_PORT || "27017";
const DB_NAME = process.env.MONGO_DB || "todos";
const MONGO_URI = `mongodb://${DB_HOST}:${DB_PORT}`;

// Connect to MongoDB
mongoose
  .connect(MONGO_URI, {
    dbName: DB_NAME,
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("Connected to MongoDB"))
  .catch((error) => console.error("MongoDB connection error:", error));

app.use("/api/todos", todoRouter);

// Routes
app.get("/", async (req, res) => {
  try {
    //const Todo = await TodoModel.find();
    res.send("Todo");
  } catch (e) {
    console.log(e);
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
