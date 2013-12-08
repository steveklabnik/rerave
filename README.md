# Rerave

A gem to calculate scores for [ReRave](http://www.rerave.com).

## Installation

Add this line to your application's Gemfile:

    gem 'rerave'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rerave

## Usage

As of right now, the gem will calculate which song a give user should play
next, based on how far away they are from the highest score.

Example:

```bash
$ rerave next steveklabnik
Scraping top scores..........done.
Scraping scores for steveklabnik
............................................................................................done.
Here are the songs steveklabnik should play next:
#1: Your Own Destiny: master (63829)
#2: Got The Rhythm: master (30314)
#3: Delirium: master (29185)
#4: Hookie Mammoth: master (24065)
#5: Stream: master (19490)
#6: Once Again: master (12520)
#7: Tricky Disco 2k10: master (11458)
#8: Insomnia: master (11431)
#9: Dam Dadi Doo: master (10732)
#10: Rock That Style: master (10061)
#11: Rome0 & Juli8: master (9904)
#12: Ignition Starts: master (9286)
#13: Popcorn: master (9124)
#14: Contrast: master (9120)
#15: Subzero: master (8964)
#16: Bits & Bytes: master (8669)
#17: Rock N' Russia: master (8055)
#18: The Pure And The Tainted: master (7732)
#19: London Bridge: master (7597)
#20: Who R You: master (6865)
$
```

As of right now, it will only calculate scores for iOS.

It caches scores locally as to not hammer ReRave's servers over and over.

To clear the cache:

```bash
$ rerave clear
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
