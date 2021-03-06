class User < ActiveRecord::Base
	attr_accessor :remember_token
	has_many :comments, dependent: :destroy
	has_many :entries, dependent: :destroy
	has_many :active_relationships, class_name: "Relationship",
								foreign_key: "follower_id", 
								dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship", 
									foreign_key: "followed_id", 
									dependent: :destroy
	has_many :following, through: :active_relationships, source: :followed								
	has_many :followers, through: :passive_relationships, source: :follower

	validates :name, presence: true, length: {maximum: 50}	
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, 
				format: {with: VALID_EMAIL_REGEX},
				uniqueness: {case_sensitive: false}
	has_secure_password
	validates :password, presence: true, length: {minimum: 6}

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    	BCrypt::Password.create(string, cost: cost)
	end

  	def User.new_token
    	SecureRandom.urlsafe_base64
  	end

	def feed
		Entry.where("user_id IN (?) OR user_id = ?", following_ids, id)
	end

	def follow(other_user)
	    active_relationships.create(followed_id: other_user.id)
	end

	def unfollow(other_user)
    	active_relationships.find_by(followed_id: other_user.id).destroy
  	end

	def following?(other_user)
		self.following.include?(other_user)
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def authenticated?(attribute, token)
		digest = self.send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end
end
