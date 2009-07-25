module Roleify
  module RoleifyableController

    def self.included(base)
      base.before_filter :allowed?
    end

    #TODO make deny action configurable, now depends on Clearance

    def allowed?
      # action marked 'public', allow access even when not logged in
      return if actions_for_role(Roleify::Role::RULES[:public]).try(:include?, self.action_name)
      # no user, no role deny access
      deny_access && return unless current_user && current_user.role
      # admin user, ok
      return if current_user.role.to_sym == Roleify::Role::ADMIN.to_sym
      # else check rules
      if actions = actions_for_role(Roleify::Role::RULES[current_user.role.to_sym])
        return actions == :all || Array(actions).include?(self.action_name) || deny_access
      end
      # no rules, deny access
      deny_access
    end

    def actions_for_role(rules_for_role)
      rules_for_role[self.controller_path.gsub("/", "_").to_sym] if rules_for_role
    end

  end
end
