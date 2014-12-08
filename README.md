[ ![Codeship Status for CliveIMPISA/nbapayapp](https://codeship.com/projects/a8e894f0-5f81-0132-1861-7eb424531d0a/status)](https://codeship.com/projects/51530)
========

Uses the nbasalaryscrape gem, Sinatra and Heroku cloud platform to create a web service.
## About
[Team Pay]("https://team-pay.herokuapp.com") uses a combination of GET and POST request to display several useful information about and NBA basketball team players' salary.
It can display all the members alone; the team members and their salary information; and a list of players from any particular team total salary. Below is a list of examples of how the service can be used.

## Usage
###GET Requests
Handles:


- GET /api/v1/:teamname.json

 - returns all players and their salary information in JSON format
 - e.g https://team-pay.herokuapp.com/api/v1/mia.json


- GET /api/v1/players/:teamname.json

  - return an list of all the players on any team
  - e.g https://team-pay.herokuapp.com/api/v1/players/mia.json


- GET /api/v1/form
  - This final GET request returns a GUI form where a POST request for all players data could be done by entering a team's name and clicking the submit button
  - e.g https://team-pay.herokuapp.com/api/v1/form


- GET /api/v1/incomes/:id
  - takes: id # (1,2,3, etc.)
  - returns: json of players' total salary

***
###POST Requests
Handles:

- POST /api/v1/check
 - takes JSON: name of team and name of players
 - returns array of salary information for the specified players


- POST /api/v1/check2
 - takes JSON: name of team and name of players
 - returns array of salary totals for the specified players


- POST /api/v1/check3
  - takes JSON: name of team and name of two players
  - returns difference in players' salary


- POST /api/v1/incomes
 - record incomes request to DB
    - description (string)
    - teamnames (json array)
    - player_names (json array)
  - redirects to GET /api/v1/tutorials/:id


####sample request body and headers for POST request
POST DESTINATION
````
        https://team-pay.herokuapp.com

````
HEADERS
````
        Accept: application/json
        Content-type: application/json
````
REQUEST BODY
````
		{
		"teamname": ["PHO"],
		"player_name": ["Archie Goodwin", "Marcus Morris"]
		}
````
Post request can be run using a service like [hurl.it]("http://www.hurl.it")
or the curl command line tool.
***

##Abbreviations

Below are NBA team abbreviations

|  Team Name |Abbreviation  |
|:---------------:|:-----:|
|Pheonix Suns|PHO|
|Miami Heat|MIA|
|Atlanta Hawks |ATL|
|Boston Celtics|BOS|
|Brooklyn Nets|BRK|
|Chicago Bulls|CHI|
|Cleveland Cavaliers|CLE|
|Dallas Mavericks|DAL|
|Denver Nuggets|DEN|
|Golden State Warriors|GSW|
|Detroit Pistons|DET|
|Los Angeles Lakers|LAL|
|Los Angeles Clippers|LAC|
|Houston Rockets|HOU|
|Indiana Pacers|IND|
|Minnesota Timberwolves|MIN|
|Memphis Grizzlies| MEM|
|Milwuakee Bucks| MIL|
|New Orleans Pelicans| NOP|
|New York Knicks|NYK|
|Oklahoma City Thunder|OKC|
|Sacramento Kings| SAC|
|Washington Wizards|WAS|
|Utah Jazz| UTA|
|San Antonio Spurs|SAS|
|Toronto Raptors|TOR|
|Philadephia 76ers|PHI|
|Portland TrailBlazers|POR|
|Orlando Magic|ORL|
|Charlotte Hornets|CHO|
