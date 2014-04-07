module Redmine_watchers_by_group
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_edit_before_save(context)
      issue = context[:issue]
      current_watcher_id = issue.watchers ? issue.watchers.map{|watcher| watcher.user_id} : []
      if context[:params][:issue].key?(:watcher_user_ids)
        new_watchers = context[:params][:issue][:watcher_user_ids]
        new_watcher_id = new_watchers ? new_watchers.map{|watcher| watcher.to_i} : []

        remove_watcher = User.find(current_watcher_id - new_watcher_id)
        add_watcher = User.find(new_watcher_id - current_watcher_id)

        remove_watcher.each do |watcher|
          issue.remove_watcher(watcher)
        end

        add_watcher.each do |watcher|
          issue.add_watcher(watcher)
        end
      end
    end

    def view_issues_form_details_bottom(context={ })
      context[:watchers] = (context[:issue].project.users.sort + context[:issue].watcher_users).uniq

      user_groups = User.current.groups.map do |group|
        Group.where(lastname: group.lastname).first
      end
      context[:user_group] = user_groups

      context[:controller].send(:render_to_string, {
          :partial => 'watchers/multiselect_group',
          :locals => context
        })
    end
  end
end
