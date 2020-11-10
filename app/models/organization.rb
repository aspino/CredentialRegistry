# Organization on whose behalf publishing is done
class Organization < ActiveRecord::Base
  NOT_EMPTY = "Organization has published resources, can't be removed".freeze

  belongs_to :admin
  has_many :organization_publishers
  has_many :publishers, through: :organization_publishers
  has_many :key_pairs, dependent: :delete_all

  validates :name, presence: true
  validates :admin, presence: true

  normalize_attribute :name, with: :squish

  before_save :ensure_ctid
  after_create :create_key_pair

  def key_pair
    key_pairs.first
  end

  private

  def create_key_pair
    key_pairs.create!
  end

  def ensure_ctid
    self._ctid ||= SecureRandom.uuid
  end
end
