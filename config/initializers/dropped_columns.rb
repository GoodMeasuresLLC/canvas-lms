#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

class ActiveRecord::Base
  DROPPED_COLUMNS = {
    'abstract_courses' => %w(sis_name sis_course_code),
    'accounts' => %w(type sis_name),
    'attachments' => %w(enrollment_id),
    'course_sections' => %w(sis_cross_listed_section_id sis_cross_listed_section_sis_batch_id sticky_xlist sis_name),
    'courses' => %w(section hidden_tabs sis_name sis_course_code),
    'enrollment_terms' => %w(sis_data sis_name),
    'enrollments' => %w(invitation_email),
    'groups' => %w(sis_name),
    'pseudonyms' => %w(sis_update_data deleted_unique_id sis_source_id),
    'role_overrides' => %w(context_code),
    'users' => %w(type creation_unique_id creation_sis_batch_id creation_email sis_name),
  }.freeze

  def self.columns_with_remove_dropped_columns
    @columns_with_dropped ||= self.columns_without_remove_dropped_columns.reject { |c|
      (DROPPED_COLUMNS[self.table_name] || []).include?(c.name)
    }
  end

  def self.reset_column_information_with_remove_dropped_columns
    @columns_with_dropped = nil
    self.reset_column_information_without_remove_dropped_columns
  end

  class << self
    alias_method_chain :columns, :remove_dropped_columns
    alias_method_chain :reset_column_information, :remove_dropped_columns
  end
end
