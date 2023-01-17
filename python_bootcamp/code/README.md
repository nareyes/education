# Learn Python Programming
[Amazon](https://www.amazon.com/Learn-Python-Programming-depth-introduction/dp/1801815097)

Authors: Fabrizio Romano and Heinrich Kruger

## Contents
- Ch 1: A Gentle Introduction to Python
- Ch 2: Built-In Data Types
- Ch 3: Conditionals and Iteration
- Ch 4: Functions, the Building Blocks of Code
- Ch 5: Comprehensions and Generators
- Ch 6: OOP, Decorators, and Iterators
- Ch 7: Exceptions and COntext Managers
- Ch 8: Files and Data Persistence
- Ch 9: Cryptography and Tokens
- Ch 10: Testing
- Ch 11: Debugging and Profiling
- Ch 12: GUIs and Scripting
- Ch 13: Data Science in brief
- Ch 14: Introduction to API Development
- Ch 15: Packaging Python Applications
_____
_____
# Learn Python Programming 3rd Edition

Welcome to Learn Python Programming, 3rd Edition.

Here you can find the complete source code for this book. Every
line of code you will find in the book is in this repository, plus
all the code that we couldn't fit in the book.

## Working on a chapter

We suggest you create a dedicated virtual environment for each chapter
you wish to work on. Chapters that require third-party libraries will
have a folder inside, called `requirements`.

First you will need to create a virtual environment. If you don't know
what a virtual environment is, please read Chapter 1.

Let's now pretend you want to work on Chapter 12. First, change into the folder
for Chapter 12 (it's called `ch12`):

    $ cd ch12

Then, create a virtual environment. In this example the virtual environment
will live inside the chapter's folder, but you can choose any other folder
that might suit you better.

    $ python3.9 -m venv .venv

We have given the virtual environment folder the name `.venv`. Feel free
to choose any other name that you might want.

---

Note: the above procedure might fail in some of the chapter folders, due
to the presence of files that aren't meant to be run. If that is the case, you
should choose another folder where to place your virtual environment. You can
create one within the chapter folder itself, or place the virtual environment
outside of the chapter folder altogether.

---

Next step is to activate the virtual environment:

    $ source  .venv/bin/activate

If you're on Windows, to activate your environment, you will need to run:

    $ .venv\Scripts\activate

Next, if the `requirements` folder is present, change into it, and run
the following command for each of the `.txt` files you will find in it.
Normally there is only a `requirements.txt` file.

    $ cd requirements
    $ pip install -U -r requirements.txt
    $ cd ..  # this brings you back to the root of the chapter

Once you have installed all requirements, you are ready to run the
chapter's code. If a chapter needs extra work to be set up, you will
find all the instructions you need in the chapter's text.

**Note**:
Always remember to activate the virtual environment before you install
third-party libraries.
### Download a free PDF

 <i>If you have already purchased a print or Kindle version of this book, you can get a DRM-free PDF version at no cost.<br>Simply click on the link to claim your free PDF.</i>
<p align="center"> <a href="https://packt.link/free-ebook/9781801815093">https://packt.link/free-ebook/9781801815093 </a> </p>