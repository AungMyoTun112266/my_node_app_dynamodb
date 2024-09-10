import app from './app';


const PORT = process.env.PORT || 5000;

// Connect to MongoDB
// connectDB();

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
