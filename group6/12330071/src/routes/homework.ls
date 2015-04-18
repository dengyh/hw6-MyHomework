require! {'express', Homework: '../models/homework'}
router = express.Router!

is-authenticated = (req, res, next) -> if req.is-authenticated! then next! else res.redirect '/login'

format-time = (time) -> time.getFullYear! + '-' + (1 + time.getMonth!) + '-' + time.getDate! +
  ' ' + time.getHours! + ':' + time.getMinutes! + ':' + time.getSeconds!

fillZero = (num) -> if num < 10 then '0' + num else num

module.exports = ->
  # The index page for this homework system
  router.get '/', is-authenticated, (req, res) !->
    (error, homeworks) <- Homework.find {}
    for item in homeworks
      item.formatDeadline = format-time item.deadline
    res.render 'home',
      user: req.user
      homeworks: homeworks


  # The page for teacher to create a new homework
  router.get '/homework/create', is-authenticated, (req, res) !->
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403
    res.render 'create',
      user: req.user


  # The page for teacher to update a old homework
  router.get '/homework/update/:id', is-authenticated, (req, res) ->
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403

    (error, homework) <- Homework.findById req.params.id
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404
    homework.deadlineTime = (fillZero homework.deadline.getHours!) + ':' + (fillZero homework.deadline.getMinutes!)
    homework.deadlineDate = (fillZero homework.deadline.getFullYear!) + '-' + (fillZero homework.deadline.getMonth! + 1) + '-' + (fillZero homework.deadline.getDate!)

    res.render 'update',
      user: req.user
      homework: homework


  # The interface for teacher to update a homework
  router.post '/homework/update/:id', is-authenticated, (req, res) ->
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403
    (error, homework) <- Homework.findById req.params.id
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404

    update-homework = {
      title: req.body.title
      content: req.body.content
      deadline: new Date req.body.date + ' ' + req.body.time
      time: homework.time
      submissions: homework.submissions
    }

    update = $set: update-homework
    (error, docs) <- Homework.update {_id: req.params.id} update
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404

    res.redirect '/homework/' + req.params.id



  # The page for teacher and student to see a homework's detail
  router.get '/homework/:id', is-authenticated, (req, res) !->
    (error, homework) <- Homework.findById req.params.id
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404

    submissions = homework.submissions
    subTime = ''

    for item in submissions
      if item.studentId == req.user._id.toString!
        submission = item
        time = item.time
        subTime = format-time time

    outline = if homework.deadline > new Date! then false else true

    res.render 'homework',
      homework: homework
      subTime: subTime
      submission: submission
      outline: outline
      user: req.user


  # The interface for teacher to create a new homework
  router.post '/homework', is-authenticated, (req, res) !->
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403

    new-homework = new Homework {
      title: req.body.title
      content: req.body.content
      deadline: new Date req.body.date + ' ' + req.body.time
      time: new Date!
      submissions: []
    }
    new-homework.save (error) ->
      if error then res.render 'error',
        message: 'Error in create homework'
        status: 500
      res.redirect '/'


  # The interface for student to submit a submission of a homework
  router.post '/homework/submit/:id', is-authenticated, (req, res) !->
    (error, homework) <- Homework.findById req.params.id
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404

    if req.user.role != 'student' then res.render 'error',
      message: 'Forbbiden'
      status: 403

    submissions = homework.submissions
    submission = req.files.submission
    new-submission = {
      studentId: req.user._id
      name: submission.originalname
      url: '/uploads/' + submission.name
      grade: -1
      time: new Date! 
    }

    for item in submissions
      if item.studentId == req.user._id.toString!
        submissions.pop item
        break
    submissions.push new-submission

    update = $set: submissions: submissions
    (error, docs) <- Homework.update {_id: req.params.id} update
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404

    res.redirect '/homework/' + req.params.id


  # The interface for teacher to set the grade of the given student
  router.post '/homework/grade/:id', is-authenticated, (req, res) !->
    (error, homework) <- Homework.findById req.params.id
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403
    studentId = req.body.studentId
    grade = req.body.grade

    for item in homework.submissions
      if item.studentId == studentId
        item.grade = parseInt(grade)

    homework.save (error) ->
      if error then res.render 'error',
        message: 'Error in create homework'
        status: 500
      res.json result: true