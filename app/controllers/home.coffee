config = require '../../config/config'
express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'
Article  = mongoose.model 'Article'
IP = require '../services/ip'
QRCode = require 'qrcode'

module.exports = (app) ->
  app.use '/', router

router.get '/', (req, res, next) ->
  Article.find (err, articles) ->
    return next(err) if err
    ips = IP()
    res.render 'index',
      title: 'Three.js VR experiment'
      articles: articles
      ip: ips[0]
      info: [
        'IPs ' + ips.map((ip) -> "#{ip}:#{config.port}").join ', '
      ]

router.get '/qrcode', (req, res, next) ->
  ip = IP()[0]
  path = "#{config.tmp}/#{ip}.png"
  QRCode.save path, "http://#{ip}", (err) ->
    if not err
      res.sendFile path
    else
      next err
