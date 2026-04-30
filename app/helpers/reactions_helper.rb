module ReactionsHelper
  EMOJI_MAP = {
    "like"  => "👍",
    "love"  => "❤️",
    "haha"  => "😂",
    "wow"   => "😮",
    "sad"   => "😢",
    "angry" => "😡"
  }.freeze

  def type_emoji(type)
    EMOJI_MAP.fetch(type.to_s, "👍")
  end
end