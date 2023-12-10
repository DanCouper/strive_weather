# README


## Overview

Web application that displays the weather for the three Strive offices, making 
use of the OpenWeatherMap API (API key + office locations provided in test).

## Setup Notes

I am *not* focussing on deployment best practices here, nor am I emulating an
existing older codebase. This is outside the scope of the task.

| Tool  | Version |
| ----- | ------- |
| Ruby  | 3.2.2   |
| Rails | 7.1.2   |

There is an API key provided for the [Open Weather Map](openweathermap.org/) API.

Note that this is for the free tier, which provides access to:

1. [the current weather at a location](https://openweathermap.org/current), and
2. [a 5-day forecast](https://openweathermap.org/forecast5) (which provides the forecast in 3-hour intervals).

To set up and run the application, assuming the specified Ruby version is 
installed, `cd` into this project directory, and run:

```
gem install
```

Followed by:

```
rails server
```

This should start a rails server at http://127.0.0.1:3000

## Initial steps

- [x] Initialise basic minimal Rails install.
- [x] Add Open Weather Map API key to the Rails user config secrets.
- [x] Add simple functional sketch of service object that hits Open Weather Map API.
- [x] Dump the data into the app:
    - [x] Add a route (`weathertest`)
    - [x] Add a controller that calls the OWM API & grabs data.
    - [x] Add a view that displays that data on an HTML page.

### Notes: Rails setup

Note that this is a minimal install (`rails new strive_weather --minimal`) which
strips out a large chunk of gems that have no relevance here (mailer, websockets,
sprockets, etc).


### Notes: Credentials

The OpenWeatherMap API key is stored in the standard Rails credentials file.

---

_I don't think this is something that existed last time I touched Rails, so the
following is a note for myself._

To *edit* the credentials file (where `EDITOR` is editor of choice):

```
EDITOR=vim rails credentials:edit
```

This will decrypt the file, and the api key data is defined like so:
 
```yml
open_weather_map:
  api_key: 'supersecretkey'
```

To *use* the value:

```
Rails.application.credentials.open_weather_map[:api_key]
```

---

> **NOTE** It would probably be sensible to check for the key on server
> initialisation, and explode immediately if it isn't found. It would probably
> also be sensible to provide a, say, `Settings` or `AppSettings` or whatever
> service that provides the value to the rest of the application, rather than
> referencing directly in the business logic.
>
> But given there's only one secret value I need here, just going to grab 
> it directly in-app.


### Notes: service object sketch

From reading up on HTTP clients, the _de facto_ standard seems to be
[Faraday](https://lostisland.github.io/faraday/), which fixes some problems
with the stdlib's `Net::HTTP`, and doesn't have some of the issues
[HTTParty](https://github.com/jnunemaker/httparty) (the previous _de facto_
standard client) has.

So the `OpenWeatherMapService` class leverages Faraday.

It includes explicit methods for hitting both the endpoint specified
in the test and the `forecast` API, I'll get back to why later on.

It does not error: both methods return an object specifying the response code
and either `:data` or an `:err` field that holds an error message. There is
also a `:url` field for debugging purposes.

---

To test in console (`rails console`), example commands:

```
require './app/services/open_weather_map_service.rb'
owm = OpenWeatherMapService.new()
lat = 54.971250
lon = -1.614590
owm.current_weather_for(lat, lon)
```

---

For app purposes, ther is a route (`weather_api`), a controller
(`weather_api_controller`) with an `index` method, and an associated view. This
prints out the current weather for the three offices.


## Finally

This fulfils the basics of the task. There are no tests or visual styling, and 
what is printed is a raw JSON response. But is does show the current weather
at all three locations.
