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
- [ ] Add simple functional sketch of service object that hits Open Weather Map API.
- [ ] Dump the data into the app:
    - [ ] Add a route (`weathertest`)
    - [ ] Add a controller that calls the OWM API & grabs data.
    - [ ] Add a view that displays that data on an HTML page.


The OpenWeatherMap API key is stored in the standard Rails credentials file.

I don't think this is something that existed last time I touched Rails, so as a
note mainly for myself:

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

> **NOTE** It would probably be sensible to check for the key on server
> initialisation, and explode immediately if it isn't found. It would probably
> also be sensible to provide a, say, `Settings` or `AppSettings` or whatever
> service that provides the value to the rest of the application, rather than
> referencing directly in the business logic.
>
> But given there's only one secret value I need here, just going to grab 
> it directly in-app.
