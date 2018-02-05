# Song and Lyric Data Scraper

This command line tool accompanies Long & Eveland (forthcoming) as a means for
others to get at the same or similar underlying data plus some other useful 
goodies. In short, the tool does the following:

* Scrapes historical Billboard charts (songs and albums) for specified genres.
* For albums, uses Discogs and/or Spotify to find tracklists.
* Searches for and stores lyrics for songs found on Billboard charts at
[MetroLyrics](http://metrolyrics.com) and [Wikia](http://lyrics.wikia.com).
* Grabs additional data, like audio qualities, via the Spotify API.  

This is all stored in a SQLite database.

## Installation

### Ruby

This app requires [*Ruby*](https://www.ruby-lang.org), a widely-used programming
language that works on virtually all commonly used operating systems. There is 
more detailed information [here](https://www.ruby-lang.org/en/documentation/installation/),
but I'll give a few suggestions.

#### macOS or Linux

I suggest installing Ruby via `rvm`, a command line program that allows you to
manage multiple Ruby installations at once and, most important, makes it easy
to download a specifiy Ruby version. More details at [RVM's website](http://rvm.io/).

I do not believe the built-in Ruby on macOS will work. This has only been tested
with Ruby 2.4.3 and I suggest you find a way to install that version of Ruby.

#### Windows

Windows users are best off going to the 
[Ruby Installer site](https://rubyinstaller.org/downloads/) and choosing the 
2.4.3 installer (or whichever version offered that begins with 2.4).

### This tool

Download this repository. Now it's installed :)

Open up a terminal (or on Windows, command prompt) and set the working 
directory to wherever you downloaded this repository. First, install
the `bundler` gem.

`gem install bundler`

Then use `bundler` to install all the other gems this tool depends on.

`bundler install`

If there are problems, one option is to run `bundler update` instead.

## Usage

### Configuration

This tool can do quite a few things and you probably don't want to do 
them all at once. The `config.yaml` file is where you control what
this library does on each run. It is mostly self-explanatory, but
the idea here is that you don't need to scrape the Billboard charts 
more than once (unless adding new songs/genres/years) and you might 
want to customize how the lyric search is done, how you deal with 
metadata and so on.

To use Spotify, you will need to create an "application" and get the
associated keys with Spotify. Just follow 
[this link](https://beta.developer.spotify.com/dashboard/), sign in
or create a Spotify account, and create an app. This doesn't mean you
program an app, just give a name to the authentication keys that Spotify
provides. You can then copy them to the appropriate places in 
`config.yaml`.

To use Discogs, which if you don't use Spotify will be necessary to
get tracklists for albums, go to their 
[API site](https://www.discogs.com/developers/), click "Create an App",
then make your account and get the required authentication token. Put
that into `config.yaml`.

### Running the app

Using the command line, assuming you followed the installation instructions,
enter the following command while your session is in this repository's folder:

`ruby main.rb`

The tool will regularly provide updates on its progress. Be warned that it can
take a very long time depending on what you ask it to do. It probably ran
for more than 24 hours straight to do all the necessary data collection for the
publication associated with this tool.

### Get the data

All the resulting data is stored in a SQLite database in the path you specify
in `config.yaml`. You will need to know something about SQL to get the data 
into other formats. Unfortunately, this is just the only efficient way to store
relational data that would be absolutely huge if we stored it in a format in 
which each Billboard entry had all of the song's information.

I like [DB Browser](http://sqlitebrowser.org/) as a cross platform GUI for 
exploring SQLite databases. You can try out select statements and export to
CSV and similar formats as needed.

## Questions?

Create an issue here on Github or email me at long.1377@osu.edu.
