require! ['mongoose']

module.exports = mongoose.model 'Homework', {
  id: String,
  title: String,
  content: String,
  time: Date,
  deadline: Date,
  submissions: [{
    studentId: String,
    url: String,
    name: String,
    grade: Number,
    time: Date
  }]
}