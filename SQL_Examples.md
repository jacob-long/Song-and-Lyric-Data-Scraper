## Basics

I'm going to write this assuming you, like me, have some familiarity
with SQL but not enough to just extemporaneously generate correct syntax.
This can also be useful if you're confused about the structure of the 
database.

As far as the structure is concerned, there are is a `master` table detailing
all songs. Likewise, there is an `album_master` table for each unique album.

Then there are tables for each chart, with a single row for each song within
each week of each year. In other words, it's highly redundant, which is why
we need a database to store the details about each song separately and 
non-redundantly.

## Get all songs from a genre

What you'll be doing most of the time, I think, is grabbing all songs from 
`master` that appear in one of the genre tables.

Here's how you might do that for R&B/hip hop:

```sql
SELECT * FROM master
WHERE master.id IN 
		( SELECT DISTINCT song_id FROM [R&B/hip hop] )
```

You're joining the `song_id` column from `R&B/hip hop` on the `id` column in
`master`. This gives you every unique song from `R&B/hip hop` with no
redundancy.

## Get all songs from a genre in a specific time period

A slight extension would be to filter by year:

```sql
SELECT * FROM master
WHERE master.id IN 
		( SELECT DISTINCT song_id FROM [R&B/hip hop] 
		WHERE [R&B/hip hop].year > 2010 )
```

This amendment would restrict the results only to those songs that charter after 
2010.

To confine it further, you could add another condition:

```sql
SELECT * FROM master
WHERE master.id IN 
		( SELECT DISTINCT song_id FROM [R&B/hip hop] 
		WHERE [R&B/hip hop].year > 2010 AND
        [R&B/hip hop].year < 2013 )
```

If you plan to do cross-genre comparisons, you'll need to find some way to 
label the outputted table from each select statement. For instance, I first
exported one CSV for each select statement, naming that file `rap.csv`,
`pop.csv`, and so on. Then, I imported each into R as a data frame, added
a column called `genre`, and labeled each data frame's `genre` column as their
genre. Then I combined them all together with `rbind`. 

There are other ways to do this, even with more convoluted SQL syntax, but 
you'll have to decide how to keep it all straight.

## Get the charts time series with song data

On the other hand, you might really care most about the rankings of songs and/or
their trends over time. This means you will need to assemble a larger table
with your select statement.

Here's an example that pulls all the songs that charted in `R&B/hip hop`
along with each week in the chart's metadata.

```sql
SELECT * FROM [R&B/hip hop]
JOIN master ON [R&B/hip hop].song_id = master.id 
```

You can subsequently apply some of the same subsetting procedures with
regard to date and so on.

```sql
SELECT * FROM [R&B/hip hop]
JOIN master ON [R&B/hip hop].song_id = master.id 
WHERE [R&B/hip hop].year > 2010 AND 
      [R&B/hip hop].year < 2013 
```

