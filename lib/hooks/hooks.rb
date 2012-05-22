module Redmine_watchers_by_group
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_edit_before_save(context)
      issue = context[:issue]
      context[:params][:issue][:watcher_user_ids].each do |watcher_id|
        watcher = User.find(watcher_id)
        if issue.addable_watcher_users.include?(watcher)
          issue.add_watcher(watcher)
        end
      end
    end
    def view_issues_form_details_bottom(context={ })
      context[:watchers] = (context[:issue].project.users.sort + context[:issue].watcher_users).uniq

      context[:controller].send(:render_to_string, {
          :partial => 'watchers/multiselect_group',
          :locals => context
        })
    end
  end
end
