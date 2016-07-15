require 'singleton'

class Library
  include Singleton

  attr_accessor :calendar, :books_available, :my_array, :members, :serve, :open, :book_ids

  #calendar object
  # my_array an array that reads and stores the lines of text file
  # books_available array that stores the book objects
  # members dictionary of members
  # open boolean library open or closed
  # serve - current member being served
  # book_ids list of book ids returned from search method

  def initialize
    calendar = Calendar.instance
    @calendar = calendar
    my_array = IO.readlines('collections.txt')
    books_available = Array.new
    book_ids = Array.new

    my_array.each_with_index do |line, index|
      title, author = line.chomp.split(/,/)
      id = index + 1
      books_available << Book.new(id, title, author)
    end

    @members = Hash.new

    @open = false

    @serve = nil

    @books_available = books_available

    @book_ids = book_ids

  end

  def open()
    raise 'The library is already open!' if @open

    @calendar.advance
    @open = true
    puts "Today is day #{calendar.get_date}"

  end

  def find_all_overdue_books
    raise 'The library is not open!' unless @open
    current_date = calendar.get_date

    members.each do |k, v|
      book_list = v.get_books
      book_list.each_index do |n|
        if current_date > book_list[n].get_due_date
          puts "#{k} #{book_list[n].to_s} "
        else
          puts "#{k} No books are overdue "
        end
      end
    end

  end

  def issue_card(name_of_member)

    raise 'The library is not open!' unless @open

    if result = members.member?(name_of_member)
      puts "#{name_of_member} already has a library card."
    else
      members.store(name_of_member, Member.new(name_of_member, self))
      puts "Library card is issued to #{name_of_member}."
    end

  end

  # @param [members] name_of_member
  # quits serving the previous member
  def serve(name_of_member)
    raise 'The library is not open!' unless @open

    @serve = nil

    result = members.include?(name_of_member)

    puts " #{name_of_member} does not have a library card." unless result

    temp = members.fetch(name_of_member)
    @serve = temp
    puts " Now serving #{name_of_member}."


  end

  def find_overdue_books
    raise 'The library is not open!' unless @open
    raise 'No member is currently being served' unless @serve
    current_date = calendar.get_date

    book_list = @serve.get_books
    book_list.each_index do |n|
      if current_date > book_list[n].get_due_date
        puts "#{@serve.get_name} #{book_list[n].to_s} "
      else
        puts 'None'
      end
    end
  end

  def check_in(*book_ids) # = 1..n book numbers

    raise 'The library is not open!' unless @open

    if @serve == nil
      raise 'No member is currently being served.'
    else

      count = 0

      book_ids.each_index do |i|

        y = book_ids.at(i)


        @serve.books_out.each_index do |n|

          book1 = @serve.books_out.at(n)
          x = book1.get_id

          if x == y
            book1.check_in
            @serve.give_back(book1)
            @books_available.push book1
            count = count + 1
          end

        end


        if count == 0
          puts "The library does not have book #{y}."
        else
          puts "#{@serve.get_name} has returned #{count} books"
        end

      end
    end
  end


  def search(string)
    raise 'The library is not open!' unless @open
    myStr = string
    count = 0
    pattern = Regexp.new(myStr, 'i')
    unless myStr.length >= 4
      puts 'Search string must contain at least four characters'
    else

      books_available.each_with_index do |line, index|
        tempString = line.to_s
        if tempString =~ pattern
          puts line
          temp_object = books_available.at(index)
          book_ids << temp_object.get_id
          count = count + 1
        end
      end

      if count == 0
        puts 'No books found'
      end

    end

  end

  def check_out(*book_ids) # = 1..n book ids

    raise 'The library is not open!' unless @open

    if @serve == nil
      raise 'No member is currently being served.'
    else

      count = 0

      book_ids.each_index do |i|

        y = book_ids.at(i)

        books_available.each_index do |n|

          book1 = @books_available.at(n)
          x = book1.get_id

          if x == y
            ddate = book1.get_due_date
            book1.check_out(ddate)
            @serve.check_out(book1)
            @books_available.delete_at(n)
            count = count + 1
          end

        end


        if count == 0
          puts "The library does not have book #{y}."
        else
          puts "#{count} books have been checked out to #{@serve.get_name}."
        end

      end

    end

  end


  def renew(*book_ids)
    raise 'The library is not open!' unless @open

    if @serve == nil
      raise 'No member is currently being served.'
    else
      count = 0
      book_ids.each_index do |i|

        y = book_ids.at(i)

        @serve.books_out.each_index do |n|

          book1 = @serve.books_out.at(n)
          x = book1.get_id

          if x == y
            date = book1.get_due_date
            book1.check_out(date)
            count = count + 1
          else
            puts "The member does not have book #{y}."
          end

        end


        if count == 0
          puts "The library does not have book #{y}."
        else
          puts "#{count} books have been renewed for #{@serve.get_name}."
        end

      end
    end

  end

  def close
    raise 'The library is not open!' unless @open
    @open = false
    puts 'Good night'
  end

  def quit

    puts 'The library is now closed for renovations'

  end

end

class Calendar
  require 'date'
  include Singleton
  attr_accessor :date

  def initialize()

    @date = 0
  end

  #Returns (as an integer) the current date.

  def get_date()
    @date
  end

  #Increment the date (move ahead to the next day), and returns the new date.

  def advance()
    @date = @date + 1
  end

end


class Book

# A book has these attributes (instance variables): id, title,
# author (only one author per book), and due_date.
# The due date is nil if the book is not checked out.

  attr_accessor :due_date

#The constructor. Saves the provided information. When created, the book is not checked out.

  def
  initialize(id, title, author)
    @id = id
    @title = title
    @author = author
    @due_date = nil
  end


# Returns this book's unique identification number.
  def get_id()
    @id
  end

#Returns this book's title.

  def
  get_title()
    @title
  end

#Returns this book's author.
  def
  get_author()
    @author
  end

#Returns the date that this book is due.

  def
  get_due_date()
    @due_date
  end

#Sets the due date of this Book.
  def
  check_out(due_date)

    if @due_date == nil
      @due_date = 0
    end

    @due_date += 7

  end

#Sets the due date of this Book to nil.
  def
  check_in()
    @due_date = nil
  end

#Returns a string of the form "id: title, by author”.
  def
  to_s()
    "Book id: #{@id}, Title: #{@title}, By author:  #{@author}"
  end

end

class Member

  # A member is a "customer" of the library.

  attr_accessor :close, :books_out, :book, :notice, :library

  BOOK_LIMIT = 3
  # Constructs a member with the given name, and no books.
  # The member must also have a reference to the Library object that he/she uses.

  def
  initialize(name, library)
    @name = name
    @library = library
    books_out = []
    @books_out = books_out
    @notice = 'this book is overdue'
  end

  #Returns this member's name.

  def
  get_name()
    @name
  end

  #Adds this Book object to the set of books checked out by this member.
  # A member must have a library card in order to check out books.
  # A member with a card may have no more than three books checked out at any time.
  def
  check_out(book)

    puts "#{self.get_name} does not have a library card" unless @library.members.member?(self.get_name)

    if @books_out.length < BOOK_LIMIT
      books_out << book
    end

  end


  #Removes this Book object from the set of books checked out by this member.
  # (Since members are usually said to "return" books, this method should be called return !)
  def give_back(book)
    books_out.delete_if { |book| books_out.include?(book) }

  end


  #Returns the set of Book objects checked out to this member (may be the empty set.)
  def get_books()
    @books_out
  end


  # Tells this member that he/she has overdue books.
  # (What the method actually does is just print out this member's name along with the notice.)
  def send_overdue_notice(notice)
    p "Reminder #{get_name} #{notice}"
  end


end



