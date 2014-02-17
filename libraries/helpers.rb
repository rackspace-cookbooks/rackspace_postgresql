module Format
  def format_postgresql_config(hash)
    _=[]
    hash.sort.map do |key, value|
      unless value.to_s.empty?
        value = case value
        when TrueClass
          "on"
        when FalseClass
          "off"
        else
          value.to_s
        end
        _ << "#{key} = #{value}"
      end
    end
    _
  end
end
#<% node['rackspace_postgresql']['config'].sort.each do |key, value| -%>
#  <% unless value.to_s.empty? -%>
#    <%= key -%> = <% case value when TrueClass then puts "on" when FalseClass then puts "off" else puts value.to_s end %>
#<% end -%>
#<% end -%>
