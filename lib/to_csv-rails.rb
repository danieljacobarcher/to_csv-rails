# -*- encoding : utf-8 -*-
class Array

  def to_csv(options = {})
    return '' if self.empty?

    options.reverse_merge!(:header => true)
    
    if options[:group]
      group = Group.find_by_token(options[:group])
    end
    #columns = self.first.class.content_columns # not include the ID column
    if options[:only]
      columns = Array(options[:only]).map(&:to_sym)
    else
      columns = self.first.class.column_names.map(&:to_sym) - Array(options[:except]).map(&:to_sym)
    end

    return '' if columns.empty?

    data = []
    # header
    if options[:header]
      header_columns = options[:header_columns].blank? ? columns.map(&:to_s).map(&:humanize) : options[:header_columns]
      data << header_columns.join(',')
      data << group.info_1_title+','+group.info_2_title if options[:group]
    end

    self.each do |obj|
      data << columns.map do |column|
        begin
          column_value = obj.send(column).to_s
          column_value.include?(",") ? "\"#{column_value}\"" : column_value
        rescue
          ''
        end
      data << obj.infos.where(group_id: group.id).info_1 if options[:group]
      data << obj.infos.where(group_id: group.id).info_2 if options[:group]
      end.join(',')
    end
    raise data.inspect
    data.join("\n")
  end

end
