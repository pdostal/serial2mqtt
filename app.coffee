moment = require 'moment'

SerialPort = require 'serialport'
Serialport = SerialPort.SerialPort
serialport = new Serialport '/dev/ttyUSB0',
  baudrate: 57600
  parser: SerialPort.parsers.readline '\n'

serialport.on 'open', ->
  serialport.write 'WHO AM I?\n', (err, results) ->

Mqtt = require 'mqtt'
mqtt = Mqtt.connect { host: 'iot.siliconhill.cz', port: 1883, protocolId: 'MQIsdp', protocolVersion: 3 }

mqtt.on 'connect', ->
  mqtt.subscribe '/pdostalcz/+/message'

mqtt.on 'message', (topic, message) ->
  console.log moment().format() + ' ' + topic.toString() + ' ' + message.toString()

serialport.on 'data', (data) ->
  if /^\[[0-9]+\] [A-Z]+-[0-9A-Z]+ .+$/g.test data
    sensor = data.replace /^\[[0-9]+\] ([A-Z]+-[0-9A-Z]+) .+$/g, '$1'
    message = data.replace /^\[[0-9]+\] [A-Z]+-[0-9A-Z]+ (.+)$/g, '$1'
    message = message.replace /((INT|SET):[0-9.]+).C/g, '$1C'
    timestamp = moment.utc().format()

    mqtt.publish '/pdostalcz/' + sensor.toLowerCase() + '/timestamp', timestamp, { retain: true }
    mqtt.publish '/pdostalcz/' + sensor.toLowerCase() + '/message', message, { retain: true }

