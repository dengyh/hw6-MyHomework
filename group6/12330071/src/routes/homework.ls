require! {'express', Homework: '../models/homework'}
router = express.Router!

is-authenticated = (req, res, next) -> if req.is-authenticated! then next! else res.redirect '/login'

format-time = (time) -> time.getFullYear! + '-' + (1 + time.getMonth!) + '-' + time.getDate! +
  ' ' + time.getHours! + ':' + time.getMinutes! + ':' + time.getSeconds!

module.exports = ->
  router.get '/', is-authenticated, (req, res) !->
    (error, homeworks) <- Homework.find {}
    for item in homeworks
      item.formatDeadline = format-time item.deadline
    res.render 'home',
      user: req.user
      homeworks: homeworks

  router.get '/homework/create', is-authenticated, (req, res) !->
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403
    res.render 'create',
      user: req.user

  router.get '/homework/update/:id', is-authenticated, (req, res) ->
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403

    (error, homework) <- Homework.findById req.params.id
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404
    res.render 'update',
      user: req.user
      homework: homework

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
      deadline: new Date req.body.year, (req.body.month - 1), req.body.day, req.body.hour
      time: homework.time
      submissions: homework.submissions
    }

    update = $set: update-homework
    (error, docs) <- Homework.update {_id: req.params.id} update
    if error then res.render 'error',
      message: 'Not Found Homework'
      status: 404

    res.redirect '/homework/' + req.params.id

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

    res.render 'homework',
      homework: homework
      subTime: subTime
      submission: submission
      user: req.user

  router.post '/homework', is-authenticated, (req, res) !->
    if req.user.role != 'teacher' then res.render 'error',
      message: 'Forbbiden'
      status: 403

    new-homework = new Homework {
      title: req.body.title
      content: req.body.content
      deadline: new Date req.body.year, (req.body.month - 1), req.body.day, req.body.hour
      time: new Date!
      submissions: []
    }
    new-homework.save (error) ->
      if error then res.render 'error',
        message: 'Error in create homework'
        status: 500
      res.redirect '/'

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

    