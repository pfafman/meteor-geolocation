#
#  Geolocation Package
#

#
# Defaults
#

options = 
  persistent: true
  lazyLastPosition: false
  distanceFilter:
    enabled: false
    range: 5
  timeFilter:
    enabled: false
    span: 120
  accuracyFilter:
    enabled: false
    rating: 12

watchOptions = 
  enableHighAccuracy: true
  maximumAge: 0

positionOptions = 
  enableHighAccuracy: true
  maximumAge: 0


#
# Local reactive vars
#

reactiveLocation = new ReactiveVar(null)
locationError    = new ReactiveVar(null)


#
# Local functions
#

storePosition = (pos) ->
  posObj = 
    latitude: pos.coords.latitude
    longitude: pos.coords.longitude
    accuracy: pos.coords.accuracy
    altitudeAccuracy: pos.coords.altitudeAccuracy
    speed: pos.coords.speed
    heading: pos.coords.heading
    updatedAt: pos.timestamp

  posString = JSON.stringify(posObj)
  
  if options.persistent
    localStorage?.setItem('meteorGeolocation:lastPosition', posString)
  
  reactiveLocation.set posObj
  posObj


filter = (pos) ->
  
  old = Location?.getLastPosition()
  if not old
    return pos  # We havent gotten a single position yet

  
  if Location._options.distanceFilter.enabled
    console.log('Filtering distance') if Location.debug 
    distance = getDistance(old, pos)
    
    console.log('Distance Filter: Filter - ' + Location._options.distanceFilter.range + '. Actual Distance - ' + distance) if Location.debug 
    
    if distance < Location._options.distanceFilter.range
      return

  if Location._options.timeFilter.enabled
    oldEnough = isSecondsAway(new Date(old.updatedAt), Location._options.timeFilter.span)
    console.log('Time Filter: Filter - Has Been ' + Location._options.timeFilter.span + ' Seconds? ' + oldEnough) if Location.debug
    if not oldEnough
      return

  if Location._options.accuracyFilter.enabled and pos.coords.accuracy and !isNaN(pos.coords.accuracy)
    console.log('Accuracy' + pos.coords.accuracy) if Location.debug 
    if pos.coords.accuracy > Location._options.accuracyFilter.rating
      console.log('Accuracy filter: Not accurate enough') if Location.debug 
      return
  
  pos


hanldeLocationError = (err) ->
  console.log("Location Error", err)
  locationError.set(err)
  Location.errorCallback?(err)


#
# Local Helpers
#

rad = (x) ->
  x * Math.PI / 180


getDistance = (p1, p2) ->
  if p1 and p2
    console.log('Getting distance for', p1, p2) if Location.debug 
    R = 6378137
    # Earth’s mean radius in meter
    dLat = rad(p2.coords.latitude - p1.latitude)
    dLong = rad(p2.coords.longitude - p1.longitude)
    a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(rad(p1.latitude)) * Math.cos(rad(p2.coords.latitude)) * Math.sin(dLong / 2) * Math.sin(dLong / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    R * c # returns the distance in meters
    

isSecondsAway = (date, seconds) ->
  now = new Date
  console.log('Time Calc: ' + now.getTime() - date.getTime()) if Location.debug 
  console.log(seconds + ' Seconds: ' + seconds * 1000 + ' In Milliseconds') if Location.debug 
  now.getTime() - date.getTime() > seconds * 1000


#
#  Exposed Location object
#

Location =
  _options: options
  _watchOptions: watchOptions
  _positionOptions: positionOptions
  _position: null
  _watching: false
  _watchId: null
  debug: false

  
  getReactivePosition: ->
    reactiveLocation.get()


  getLastPosition: ->
    if options.persistent
      lastPos = localStorage.getItem('meteorGeolocation:lastPosition')
      if lastPos
        return JSON.parse(lastPos)
    else
      console.log 'Location Error: You\'ve set perstitent storage to false'
    

  locate: (callback) ->
    navigator?.geolocation?.getCurrentPosition (pos) ->
      console.log('Get Current Position Received New Position: ' + JSON.stringify(pos)) if Location.debug
      filteredPos = filter(pos)
      if filteredPos
        fixed = storePosition(filteredPos)
        callback?(fixed)
    , hanldeLocationError, @_positionOptions
    

  startWatching: (callback) ->
    if not @_watching and navigator.geolocation?
      @_watchId = navigator.geolocation.watchPosition (pos) ->
        console.log('Start Watching Received New Position: ' + JSON.stringify(pos)) if Location.debug
        filteredPos = filter(pos)
        if filteredPos
          fixed = storePosition(filteredPos)
          callback?(fixed)
      , hanldeLocationError, @_watchOptions
      @_watching = true
    

  stopWatching: ->
    if @_watching and navigator.geolocation
      navigator.geolocation.clearWatch(@_watchId)
      @_watching = false
    

  setWatchOptions: (options) ->
    if not options
      console.log 'You must provide an options object'
    else
      @_watchOptions = options
    

  isWatchind: ->
    @_watching not false


  setGetPositionOptions: (options) ->
    if not options
      console.log 'You must provide an options object'
    else
      @_positionOptions = options
    

  setErrorCallback: (@errorCallback) ->


  enableAccuracyFilter: (rating) ->
    @_options.accuracyFilter.enabled = true
    @_options.accuracyFilter.rating = rating
    

  disableAccuracyFilter: ->
    @_options.accuracyFilter.enabled = false
    

  enableDistanceFilter: (distance) ->
    @_options.distanceFilter.enabled = true
    @_options.distanceFilter.range = distance
    

  disableDistanceFilter: ->
    @_options.distanceFilter.enabled = false
    

  enableTimeFilter: (span) ->  # span in seconds
    @_options.timeFilter.enabled = true
    @_options.timeFilter.span = span
    

  disableTimeFilter: ->
    @_options.timeFilter.enabled = false
    

  disableAllFilters: ->
    @_options.accuracyFilter.enabled = false
    @_options.distanceFilter.enabled = false
    @_options.timeFilter.enabled = false
    

