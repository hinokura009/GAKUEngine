# == Schema Information
#
# Table name: assignments
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  description       :text
#  max_score         :integer
#  syllabus_id       :integer
#  grading_method_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Assignment < ActiveRecord::Base
	belongs_to :syllabus
	belongs_to :grading_method

	attr_accessible :name, :description, :max_score, :syllabus_id, :grading_method_id
end
