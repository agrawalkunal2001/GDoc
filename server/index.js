// npm init -y
// scripts- "start": "node ./index.js"
// npm i express mongoose http socket.io@2.3.0
// npm i nodemon --save-dev
const express = require("express"); // import express
const mongoose = require("mongoose"); // import mongoose
const cors = require("cors"); // import cors
const authRouter = require("./routes/auth");

const PORT = process.env.PORT | 3001;
const app = express(); // initialise express

const DB = "mongodb+srv://agrawalkunal2001:Kunal2001$@cluster0.xfdbjom.mongodb.net/?retryWrites=true&w=majority";

// middleware
app.use(cors());
app.use(express.json());
app.use(authRouter);

mongoose.connect(DB).then(() => {
    console.log("Connection successful!");
}).catch((err) => {
    console.log(err);
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Connected at port ${PORT}`);
});