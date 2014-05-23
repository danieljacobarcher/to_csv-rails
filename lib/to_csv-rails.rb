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
      if options[:group]
        data << (header_columns+[group.info_1_title, group.info_2_title]).join(',')
      else
        data << header_columns.join(',')
      end
    end
    
    tempdata = []
    
    self.each do |obj|
      tempdata << columns.map do |column|
        begin
          column_value = obj.send(column).to_s
          column_value.include?(",") ? "\"#{column_value}\"" : column_value
        rescue
          ''
        end
      end
      tempdata = tempdata + [obj.infos.where(group_id: group.id)[0].info_1, obj.infos.where(group_id: group.id)[0].info_2].to_a if options[:group]
      Rails.logger.info("*"*100)
      Rails.logger.info(tempdata)
      Rails.logger.info("*"*100)
      data << tempdata.join(',')
      Rails.logger.info("*"*100)
      Rails.logger.info(data)
      Rails.logger.info("*"*100)
    end
    data.join("\n")
  end

end
