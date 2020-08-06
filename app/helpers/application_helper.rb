module ApplicationHelper
  # def active_link_to(title, path, options={})
  #   klass = options[:class] || ''
  #   klass += " active" if path == request.path
  # end

  def page_classes
    "#{controller_path.gsub('/', '_')} #{action_name}"
  end
end
