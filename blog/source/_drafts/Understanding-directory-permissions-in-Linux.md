---
title: Understanding directory permissions in Linux
tags:
- Operating Systems
- Linux
categories:
- Learning
---

*Note: This is a work in progress.*

## Background

*Prerequisites: ECS150 Operating Systems*

In ECS 150, we learned that directories in modern file systems are actually just
files that have entries to other files. Directories in Linux is no exception.
With these knowledge in mind, we can understand the somewhat unintuitive
directory permissions.

### Files

At a high level, a file consists of a **directory entry**, an **inode**, and an
associated **data region** section.

The inode of a file contains metadata about the file such as where and how big
the file is in the data region. On the other hand, the data region holds the
actual content of the file. Notably, access control information is also held in
the inode, such as stuff like **owner** and **permission bits**. The permission
bits are what determine what someone can do to a file. ([`man 7
inode`](https://www.man7.org/linux/man-pages/man7/inode.7.html))

I'll assume that the reader knows a little about [file
permissions](https://en.wikipedia.org/wiki/File-system_permissions#POSIX_permissions)
already, so here is a quick review: The permission bits come in three types:
*read*, *write*, and *execute*. These determine how a subject can interact with
the file's *data region* -- read, write, or execute the content of the file.
([`man 7 inode`](https://www.man7.org/linux/man-pages/man7/inode.7.html))

### Directories

A directory is a file with two notable traits:
* The functionality of its `execute` permission bit is slightly different than
  normal files, which we will cover in the [next
  section](#Directory-permissions).
* The data region of the directory contains what is essentially a map from
  names to inodes.

## Directory permissions

With that, let's jump into the permissions bits of a directory! We'll start by
creating a directory without any permissions for the user `eric`.

```bash
# `sudo` makes the owner of the directory `root`
$ sudo mkdir super
# Only `root` have permission
$ sudo chmod 700 super
$ echo "Hello, world" >> public.txt
$ sudo mv public.txt super
$ ls -la
...
drwx------  2 root root  4096 Dec 27 03:17 super
$ sudo ls -la super
...
-rw-r--r-- 1 eric users   13 Dec 27 03:17 public.txt
$ sudo cat super/public.txt
Hello, world
```

### Read

As mentioned above, the *read* permission bit allows the reading of the data
region of a file. The data region of a directory is just the name-inode pairs,
something read by `ls`. So, we expect `ls` to work if we have read permission
for `super`.

```bash
$ ls super
ls: cannot open directory 'super': Permission denied
$ sudo chmod 704 super
$ ls super
# You might get a permission error here due to an alias. Try \ls in that case
public.txt
$ cat super/public.txt
cat: super/public.txt: Permission denied
```

`ls` did output the names of the file inside `super`. However, why can't I
read `super/public.txt`? Because *read* permission only allows one to
read names and which inode is associated with each name; *it does not grant
permission to read the contents of the inode*; for that, we need a different,
new-ish permission.

### Search or execute

This is the interesting part of directory permissions. The *execute* permission
is pretty intuitive on normal files, but it doesn't make much sense on
directories, **which is why Linux decided to use the bit for a different
permission: *search*.**

The *search* permission allows one to "access" files in the directory.
Essentially, it allows one to not only read the name of the files but also their
inodes. As such, reading `super/public.txt` without *search*, such as in the
case of `cat super/public.txt`, fails because one can't read a file without
accessing metadata like data region address. ([`man 2
chmod`](https://www.man7.org/linux/man-pages/man2/chmod.2.html))

#### `ls -la` without search

We can further illustrate this with `ls -l`. This command lists some of the
file's metadata such as its permission bits and owners. Without the search
permission, we get this.

```bash
$ ls -l super
ls: cannot access 'super/public.txt': Permission denied
total 0
-????????? ? ? ? ?            ? public.txt
```

We can see that `ls` is trying to access the file for its metadata and got
denied. We can only see the name of the file, provided by *read* on the
directory.

## Interesting cases

Since *write* is similar to *read*, instead of going through the *write*
permission in exhaustive detail, I'll go through some interesting case studies.

### Only *search*

Only having *search* permission is unexpectedly powerful. Here's some stuff you
can do:

```bash
~$ cd super
~/super$ cat public.txt
Hello, world
~/super$ echo "An edit with only search" >> public.txt          
~/super$ cat public.txt
Hello, world
An edit with only search
~/super$ cd ..
~$
```

### Only *write*

On the other end of the spectrum, only having *write* permissions doesn't let me
really do anything. *write* allows me to modify the data region of the
directory, essentially adding, renaming, or deleting entries in the directory.
However, all of these things also require modifications to some file metadata
such as the *last-changed* time.

```bash
$ touch super/test.txt
touch: cannot touch 'super/test.txt': Permission denied
$ mkdir super/test
mkdir: cannot create directory ‘super/test’: Permission denied
$ mv super/public.txt .
mv: cannot stat 'super/public.txt': Permission denied
$ rm super/public.txt
rm: cannot remove 'super/public.txt': Permission denied
```

## Resources

* [GNU documentation](https://www.gnu.org/software/coreutils/manual/html_node/Mode-Structure.html)
* [Redhat blog](https://www.redhat.com/en/blog/linux-file-permissions-explained)

## Expansion

1. More permission bits like sticky
2. More fun case studies
