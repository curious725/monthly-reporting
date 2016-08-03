class Holiday < ActiveRecord::Base
  validates :description, :duration, :start,
            presence: true
  validates :description,
            allow_blank: false,
            uniqueness: { case_sensitive: false },
            length: { minimum: 7, maximum: 25 }
  validates :duration,
            numericality: { only_integer: true,
                            greater_than: 0,
                            less_than: 5 }
  validates :start,
            inclusion: { in: Date.new(2013, 9, 1)..Date.new(2050, 1, 1) }

  def self.dates
    all.map(&:dates).flatten
  end

  def dates
    (start..(start + duration - 1)).to_a
  end
end
