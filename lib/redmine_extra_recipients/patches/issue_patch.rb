module RedmineExtraRecipients
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :recipients, :extra_recipients
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def recipients_with_extra_recipients
          notified = recipients_without_extra_recipients
          if Setting['plugin_redmine_extra_recipients'].present? &&
              Setting['plugin_redmine_extra_recipients']['recipients'].present?

            should_add_recipients = false;

            if Setting['plugin_redmine_extra_recipients']['private_project_visibility'] != 'custom_projects'
              should_add_recipients = project.is_public || (!project.is_public && Setting['plugin_redmine_extra_recipients']['private_project_visibility'] == 'include_private')
            else
              should_add_recipients = Setting['plugin_redmine_extra_recipients']['projects'].include?(project.id.to_s)
            end

            if Setting['plugin_redmine_extra_recipients']['new_status'].present?
              should_add_recipients &&= Setting['plugin_redmine_extra_recipients']['new_status'].include?(status.id.to_s)
            end

            if  should_add_recipients
              comma_or_newline_regex = /[,\n]/

              extra_recipients = Setting['plugin_redmine_extra_recipients']['recipients']
              notified += extra_recipients.split(comma_or_newline_regex).collect(&:strip)
            end
          end

          notified
        end
      end
    end
  end
end
