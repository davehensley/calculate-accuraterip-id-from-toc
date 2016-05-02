# Calculate AccurateRip ID from TOC

This is a simple Perl script which calculates an [AccurateRip](http://www.accuraterip.com/) ID from a compact disc's
table of contents (TOC).

The TOC should be stored in a .toc file, and should resemble the output from
[Exact Audio Copy](http://www.exactaudiocopy.de/)'s log files.

### Example:
     Track |   Start  |  Length  | Start sector | End sector
    ---------------------------------------------------------
        1  |  0:00.20 |  6:13.00 |        20    |    27994
        2  |  6:13.20 |  6:00.35 |     27995    |    55029
        3  | 12:13.55 |  4:10.02 |     55030    |    73781
        4  | 16:23.57 |  3:19.18 |     73782    |    88724
        5  | 19:43.00 |  6:00.05 |     88725    |   115729
        6  | 25:43.05 |  5:32.10 |    115730    |   140639
        7  | 31:15.15 |  3:30.07 |    140640    |   156396
        8  | 34:45.22 |  5:31.30 |    156397    |   181251
        9  | 40:16.52 | 11:22.30 |    181252    |   232431

This TOC would result in the following AccurateRip ID:

    $ ./calculate_accuraterip_id_from_toc.pl sample.toc 
    00105b83-0077b665-8b0c1b09

Due to an AccurateRip quirk, the final piece ([8b0c1b09](http://www.freedb.org/freedb/rock/8b0c1b09)) is also the freedb
ID of the disc, but to find it there you will also need to know the genre.
