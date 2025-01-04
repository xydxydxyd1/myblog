---
title: Postmortem - Schedule Builder Export
tags:
- Python
categories:
- Projects
---

## Quick Information

UC Davis' Schedule Builder is a website where students register for courses.
Schedule Builder Export takes information from that site and return an ics
calendar file to be imported to Google Calendar.

Github: https://github.com/xydxydxyd1/schedule-builder-export

Time: 2-3 hours

## Schedule Builder Export

Christmas break is almost over and school is starting again, and just as the
last 6 times, I was painstakingly transferring my school schedule from the
school website Schedule Builder to my Google calendar.

It's not news that this process is annoying. In fact, there have been attempts
at solving it. The most well-known one is a Google Chrome extension with the
exact same name as this project. However, it only worked once on my machine.
The time that it worked, it also had various problems such as the lack of
starting and ending dates for the classes. As always, I thought,

> Transferring schedules is difficult. Why don't I fix that with technology

I probably could've just spent 10 minutes copying everything over, but if I
automate this process, I would save future me and my friends' time. This is not
to mention the fact that I just wanted to make something. So, for several
minutes, I considered what I needed, what I can do, and whether I should
proceed.

### Considerations and planning

First, I considered the criteria of my project, which came down to the
following:
1. The project has to be completed today, since I have other plans before school
   starts and I want my schedule on my Google Calendar.
2. The project will transfer necessary class information to Google Calendar
    + Dates and times (starting when school starts and stops recurring once
      school ends)
    + Name
    + Description
    + Location
    + Type (Lecture/Discussion)
    + Section number

The list of information is may seem trivial but it is necessary since it impacts
how I obtain the data. Fortunately, I quickly realizes that everything I need is
on Schedule Builder.

As such, the question becomes whether I can complete this project within the
expected time frame of one day. This involves the implementation of the project,
which can be broken down into two steps: gathering the data and parsing it into
something Google Calendar understands.

#### Technical

Deciding on the target type of the parsing is easy:
[ics](https://icalendar.org/RFC-Specifications/iCalendar-RFC-5545/). This
standard saves a calendar as a `.ics` file to be used by other software. It is
widely recognized as a standard for calendars, and will most likely be easier
than working with any Google-specific API's due to its simplicity.

The input, as I mentioned before, will come from Schedule Builder. I immediately
disregarded script-based web scraping because it will add complexity to the
project when I can just f12 and find the relevant div, and for now I don't have
plans of publishing the project to the general public - that's something that I
can always work on in the future.

So, the project will look like the following:
1. Manually find relevant and compact information that is easy to copy (a
   handful of copy-pastes)
2. Parse it to extract useful information
3. Parse the information into ics format
4. Upload it to Google Calendar

> All of the code would be text processing. Seems doable in a couple hours. Let's
> do it!

## Implementation

I quickly decided on the technologies to use.
* Python: it is great for quickly scripting up something without need for
  performance or scale.
* [icalendar](https://icalendar.readthedocs.io/en/latest/index.html): a updated
  and reputable Python library for ics-related programs.
* [beautifulsoup](https://beautiful-soup-4.readthedocs.io/en/latest/) : an HTML
  processing library.

Then, I whipped up a few functions that I thought I needed:
```py
parsed_class_info = parse(raw_class_info)
calendar = to_calendar(parsed_class_info)
write_export(path, calendar)
```

Naturally I started with `parse(raw_class_info)`. I copied in some HTML and got
to work stirring the soup. It took a bit of time, which got me thinking. The
school server has all the information in a nice database. Now it's all messed up
in a bunch of HTML.

> There has to be a better way of doing this.

Then it hit me: if the school website is dynamically rendered, maybe one of the
requests asks for specifically the class information! I went searching and was
not disappointed: a consecutive list of requests titled `search.cfg` has
literally everything I needed in JSON format. That's convenient!

The rest isn't of much interest. I first got a working prototype that just makes
one event. I iterated from there, adding features from the list like recurring
events, start/end date, and final exam times, each less important than the
previous.
