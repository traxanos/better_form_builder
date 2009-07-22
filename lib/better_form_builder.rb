require 'action_view/helpers/tag_helper'

module ActiveRecord
  class Errors
    def messages_for(attribute)
      errors = @errors[attribute.to_s]
      return nil if errors.nil?
      
      errors.collect { |error| (error.at(0) == '^') ? error.slice(1..-1) : "#{@base.class.human_attribute_name(attribute.to_s)} #{error}" }
    end
  end
end

module ActionView
  class Base
    @@field_error_proc = Proc.new{ |html_tag, instance| "<span class=\"form_error\">#{html_tag}</span>" }
  end
  
  module Helpers
    
    module FormHelper
      alias_method :text_field_without_class, :text_field
      def text_field(object_name, method, options = {})
        text_field_without_class(object_name, method,merge_class_option('text_field', options))
      end
      
      alias_method :password_field_without_class, :password_field
      def password_field(object_name, method, options = {})
        password_field_without_class(object_name, method, merge_class_option('password_field', options))
      end
      
      alias_method :hidden_field_without_class, :hidden_field
      def hidden_field(object_name, method, options = {})
        hidden_field_without_class(object_name, method, merge_class_option('hidden_field', options))
      end
      
      alias_method :file_field_without_class, :file_field
      def file_field(object_name, method, options = {})
        file_field_without_class(object_name, method, merge_class_option('file_field', options))
      end
      
      alias_method :text_area_without_class, :text_area
      def text_area(object_name, method, options = {})
        text_area_without_class(object_name, method, merge_class_option('text_area', options))
      end
      
      alias_method :check_box_without_class, :check_box
      def check_box(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
        check_box_without_class(object_name, method, merge_class_option('check_box', options), checked_value, unchecked_value)
      end
      
      alias_method :radio_button_without_class, :radio_button
      def radio_button(object_name, method, tag_value, options = {})
        radio_button_without_class(object_name, method, tag_value, merge_class_option('radio_button', options))
      end
      
      private 
      def merge_class_option(css, options = {})
        options[:class] = "#{css} #{options[:class]}".strip
        options
      end
      
    end
    
    module FormTagHelper
      alias_method :text_field_tag_without_class, :text_field_tag
      def text_field_tag(name, value = nil, options = {})
        text_field_tag_without_class(name, value, merge_class_option('text_field', options))
      end

      alias_method :file_field_tag_without_class, :file_field_tag
      def file_field_tag(name, options = {})
        file_field_tag_without_class(name, merge_class_option('file_field', options))
      end

      alias_method :text_area_tag_without_class, :text_area_tag
      def text_area_tag(name, content = nil, options = {})
        text_area_tag_without_class(name, content, merge_class_option('text_area', options))
      end
      
      alias_method :check_box_tag_without_class, :check_box_tag
      def check_box_tag(name, value = "1", checked = false, options = {})
        check_box_tag_without_class(name, value, checked, merge_class_option('check_box', options))
      end
      
      alias_method :radio_button_tag_without_class, :radio_button_tag
      def radio_button_tag(name, value, checked = false, options = {})
        radio_button_tag_without_class(name, value, checked, merge_class_option('radio_button', options))
      end
      
      alias_method :submit_tag_without_class, :submit_tag
      def submit_tag(value = "Save changes", options = {})
        submit_tag_without_class(value, merge_class_option('submit', options))
      end
      
      alias_method :image_submit_tag_without_class, :image_submit_tag
      def image_submit_tag(source, options = {})
        image_submit_tag_without_class(source, merge_class_option('image', options))
      end
      
      private
      def merge_class_option(type, options = {})
        cssclass = type
        cssclass += " password" if options[:type] == 'password'
        cssclass += " hidden" if options[:type] == 'hidden'
        options[:class] = "#{cssclass} #{options[:class]}".strip
        options
      end
    end
    
    class FormBuilder
      include ::ActionView::Helpers::TagHelper
      
      def error_message(message = "the form has an error", *attributes)
        content_tag 'p', message, :class => 'form_error_message' if has_error?(*attributes)
      end
      
      def error_attributes(*attributes)
        raise ArgumentError unless attributes.is_a? Array or attributes.nil?
        attributes = attributes.collect { |attribute| attribute.to_s }
        # i don't no why this work how i need :D
        temp = @object.errors.each{ |attribute,msg| false }
        errors = temp.keys
        
        if attributes.nil? or attributes.first.blank?
          errors
        else
          errors.reject! { |field| !attributes.include? field }
        end
      end
      
      def error_list(*attributes)
        raise ArgumentError unless attributes.is_a? Array or attributes.nil?
        
        errors = error_attributes(*attributes)
        unless errors.nil? 
          unless errors.empty?
            html = String.new
            html << "<ul class=\"form_error\">"
            errors.each do |attribute|
              attribute_errors = @object.errors.messages_for(attribute)
              attribute_errors.each do |error|
                html << "<li>" + error + "</li>"
              end
            end
            html << "</ul>"
          end
        end
      end
      
      def has_error?(*attributes)
        raise ArgumentError unless attributes.is_a? Array or attributes.nil?
        errors = error_attributes(attributes)
        !errors.empty?
      end
    end
  end
end
