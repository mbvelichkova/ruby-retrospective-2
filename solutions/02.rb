class Song
  attr_accessor :name, :artist, :album

  def initialize(name, artist, album)
    @name   = name
    @artist = artist
    @album  = album
  end

  def ==(other)
    @name == other.name and
      @artist == other.artist and
      @album == other.album
  end

  alias eql? ==

  def hash
    [@name, @artist, @album].hash
  end
end

class Collection
  attr_reader :songs
  include Enumerable

  def initialize(songs)
    @songs = songs
  end

  def each(&block)
    @songs.each(&block)
  end

  def self.parse(text)
    lines = text.split("\n")
    songs = lines.each_slice(4).map do |name, artist, album|
      Song.new name, artist, album
    end

    new songs
  end

  def artists
    @songs.map(&:artist).uniq
  end

  def albums
    @songs.map(&:album).uniq
  end

  def names
    @songs.map(&:name).uniq
  end

  def filter(criteria)
    sub_songs = @songs.select { |song| criteria.satisfy(song) }
    Collection.new(sub_songs)
  end

  def adjoin(other)
    adjoined_songs = (@songs + other.songs).uniq
    Collection.new adjoined_songs
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