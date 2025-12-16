# This script makes a README.md with links to all my solutions.
# Run it with 'ruby generateReadme.rb'
# This was written using Ruby 2.5.1
# by Zack Sargent

# Start table generation

def makeColumnElement(number, width)
  width += 2 # add more spacing
  string = number
  string.prepend("| ")
  return "" if number.nil? || width - number.size <= -1
  string << (" " * (width - number.size))
  return string
end

def makeRow(array, widths)
  row = ""
  col = 0
  array.each { |ele|
    row << makeColumnElement(ele, widths[col] + 1)
    col += 1
  }
  row << "|\n"
  return row
end

def makeHeader(widths)
  row = ""
  widths.each { |width|
    row << makeColumnElement("-"*(width), width + 1)
  }
  row << "|\n"
  return row
end

def getWidths(array, cols)
  widths = []
  1.upto(cols) do |i|
    column = []
    (i..array.size).step(cols) do |j|
      column.append(array[j-1])
    end
    widths.append(column.max_by(&:length).size)
  end
  return widths
end

# makeTable takes an array of strings to be formatted as a
# markdown table. The number of elements in the array needs to
# be evenly divisble by the number of columns.
def makeTable(array, cols)
  return nil unless array.size%cols == 0
  table = []
  # width = array.max_by(&:length).size
  widths = getWidths(array, cols)

  # loop through array by row
  (1..array.size).step(cols) do |i|
    # section = row, accounting for index changes
    section = array[i-1..i+cols-2]
    table.append(makeRow(section, widths))
  end

  table.insert(1, makeHeader(widths))
  return table.join
end

# Stop table generation
# Start content generation

def getFilesInDir(dir)
  files = Dir.children(dir)
  return files
end

def makeLink(files, dirName)
  if files.size == 0
    return "#{dirName.to_i}"
  elsif files.size == 1
    return "[#{dirName.to_i}](solutions/#{dirName}/#{files[0]})"
  else
    return "[#{dirName.to_i}](solutions/#{dirName}/)"
  end
end

# takes a name of solution and the solutions,
# and returns either a link to the solution
# or the name if the solution doesn't exist
def getLink(name, solutions, language = nil)
  name = name.to_i
  if solutions.key?(name)
    return solutions[name]
  else
    return name
  end
end

def filterSolutions(solutions, language)
  def is_valid?(filename, language)
    lower_filename = filename.downcase()
    return false if lower_filename.include?(".txt")
    return false if lower_filename.include?(".swp")
    return false if lower_filename.include?(".hi")
    return false if lower_filename.include?(".o")
    return false if lower_filename.include?(".class")
    # do not keep compiled files
    return false unless lower_filename.include?(".")
    # keep if no language is specified
    return true unless language
    extension = filename[filename.size-language.size..filename.size]
    return (extension == language)
  end

  solutions.keep_if { |filename| is_valid?(filename, language) }
  return solutions
end


# represent dir as object where
# dir = {
#   folder name as integer => content to go in table cell,
#   folder name as integer => content to go in table cell,
# }

def makeFilledTable(language = nil)
  names = getFilesInDir("solutions")
  files = {}
  names.each do |name|
    solutions = getFilesInDir("solutions/#{name}")
    solutions = filterSolutions(solutions, language)
    files.store(name.to_i, makeLink(solutions, name))
  end

  arr = (1..100).to_a
  arr = arr.map { |num| getLink(num, files, language) }
  arr = arr.map(&:to_s)

  return  makeTable(arr, 10)
end

FULL_TABLE = makeFilledTable()
PYTHON_TABLE = makeFilledTable("py")
RUBY_TABLE = makeFilledTable("rb")
HASKELL_TABLE = makeFilledTable("hs")
JAVA_TABLE = makeFilledTable("java")

# Stop content generation
# Start writing to file

content = "\
# Numbered Grid Project Template.

I've done enough challenges with a numbered grid, so I figured I'd make this a reusable template for myself.

These scripts are used across:
- <https://github.com/zsarge/ProjectEuler>
- <https://github.com/zsarge/advent-of-code-2021/>
- <https://github.com/zsarge/advent-of-code-2022/>
- ... More?

This is just for my personal use. Buyer beware.

## My Project Euler solutions:
(Click a number to view the associated solution.)
<!---
  This table is automatically generated and is best viewed with line wrap off.
  I did consider reference style links, and they didn't seem much better.
  Just try and view the formatted table, if you can.
-->
#{FULL_TABLE}

[[View solutions filtered by language used]](solutionsByLanguages.md)

<br>
I have some scripts set up to make working on problems a smoother experience:

 - [`addSolution.rb`](addSolution.rb) takes a problem number, creates the associated folder and file, and copies the problem's prompt from the website.
 - [`generateReadme.rb`](generateReadme.rb) generates this readme based on the files in the solutions folder.

Every solution gets its own directory because I plan on varying the languages I use, and this keeps everything uniform.

Code by [Zack Sargent](https://github.com/zsarge).
"

File.write("README.md", content, mode: "w")

individual_tables = "\
# Solutions, filtered by language:

## [[Go back]](README.md)

## My Ruby solutions:
#{RUBY_TABLE}

## My Python solutions:
#{PYTHON_TABLE}

## My Haskell solutions:
#{HASKELL_TABLE}

## My Java solutions:
#{JAVA_TABLE}

"
File.write("solutionsByLanguages.md", individual_tables, mode: "w")

# Stop writing to file

puts "Success"
