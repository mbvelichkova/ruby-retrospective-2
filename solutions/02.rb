class Song
  attr_accessor :name, :artist, :album

  def initialize(song_description)
    @name   = song_description[0]
    @artist = song_description[1]
    @album  = song_description[2]
  end

  def ==(other)
    @name == other.name and @artist == other.artist and @album == other.album
  end
end

class Collection
  include Enumerable

  def initialize(songs)
    @songs = songs
  end

  def each
    @songs.each { |song| yield song }
  end

  def self.parse(text)
    songs = text.split("\n").each_slice(4).map do |song_description|
      Song.new(song_description)
    end
    new(songs)
  end

  def artists
    @songs.map { |song| song.artist }.uniq
  end

  def albums
    @songs.map { |song| song.album }.uniq
  end

  def names
    @songs.map { |song| song.name }.uniq
  end

  def filter(criteria)
    sub_songs = @songs.select { |song| criteria.satisfy(song) }
    Collection.new(sub_songs)
  end

  def adjoin(other_songs)
    subset = Array.new(@songs.to_a)
    filtered_songs = other_songs.select { |song| not subset.member? song }
    filtered_songs.each { |song| subset << song }
    Collection.new(subset)
  end
end

class Criteria
  def self.name(song_name)
    CriteriaSongName.new(song_name)
  end

  def self.artist(song_artist)
    CriteriaSongArtist.new(song_artist)
  end

  def self.album(song_album)
    CriteriaSongAlbum.new(song_album)
  end

  def |(other)
    Or.new(self, other)
  end

  def &(other)
    And.new(self, other)
  end

  def !
    Not.new(self)
  end
end

class CriteriaSongName < Criteria
  def initialize(song_name)
    @song_name = song_name
  end

  def satisfy(song)
    song.name == @song_name
  end
end

class CriteriaSongArtist < Criteria
  def initialize(song_artist)
    @song_artist = song_artist
  end

  def satisfy(song)
    song.artist == @song_artist
  end
end

class CriteriaSongAlbum < Criteria
  def initialize(song_album)
    @song_album = song_album
  end

  def satisfy(song)
    song.album == @song_album
  end
end

class Or
  def initialize(criteria_1, criteria_2)
    @criteria_1, @criteria_2 = criteria_1, criteria_2
  end

  def satisfy(song)
    @criteria_1.satisfy(song) | @criteria_2.satisfy(song)
  end
end

class And
  def initialize(criteria_1, criteria_2)
    @criteria_1, @criteria_2 = criteria_1, criteria_2
  end

  def satisfy(song)
    @criteria_1.satisfy(song) & @criteria_2.satisfy(song)
  end
end

class Not
  def initialize(criteria)
    @criteria = criteria
  end

  def satisfy(song)
    !@criteria.satisfy(song)
  end
end