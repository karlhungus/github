# encoding: utf-8

module Github
  class Orgs::Members < API

    # List members
    #
    # List all users who are members of an organization. A member is a user
    # that belongs to at least 1 team in the organization.
    # If the authenticated user is also a member of this organization then
    # both concealed and public members will be returned.
    # Otherwise only public members are returned.
    #
    # = Examples
    #  github = Github.new
    #  github.orgs.members.list 'org-name'
    #  github.orgs.members.list 'org-name' { |memb| ... }
    #
    # List public members
    #
    # Members of an organization can choose to have their membership publicized or not.
    # = Examples
    #  github = Github.new
    #  github.orgs.members.list 'org-name', :public => true
    #  github.orgs.members.list 'org-name', :public => true { |memb| ... }
    #
    def list(org_name, params={})
      assert_presence_of org_name
      normalize! params

      response = if params.delete('public')
        get_request("/orgs/#{org_name}/public_members", params)
      else
        get_request("/orgs/#{org_name}/members", params)
      end
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # Check if user is, publicly or privately, a member of an organization
    #
    # = Examples
    #  github = Github.new
    #  github.orgs.members.member? 'org-name', 'member-name'
    #
    # Check if a user is a public member of an organization
    #
    # = Examples
    #  github = Github.new
    #  github.orgs.members.member? 'org-name', 'member-name', :public => true
    #
    def member?(org_name, member_name, params={})
      assert_presence_of org_name, member_name
      normalize! params

      response = if params.delete('public')
        get_request("/orgs/#{org_name}/public_members/#{member_name}", params)
      else
        get_request("/orgs/#{org_name}/members/#{member_name}", params)
      end
      response.status == 204
    rescue Github::Error::NotFound
      false
    end

    # Remove a member
    # Removing a user from this list will remove them from all teams and
    # they will no longer have any access to the organization’s repositories.
    #
    # = Examples
    #  github = Github.new
    #  github.orgs.members.remove 'org-name', 'member-name'
    #
    def delete(org_name, member_name, params={})
      assert_presence_of org_name, member_name
      normalize! params
      delete_request("/orgs/#{org_name}/members/#{member_name}", params)
    end
    alias :remove :delete

    # Publicize a user’s membership
    #
    # = Examples
    #  github = Github.new :oauth_token => '...'
    #  github.orgs.members.publicize 'org-name', 'member-name'
    #
    def publicize(org_name, member_name, params={})
      assert_presence_of org_name, member_name
      normalize! params
      put_request("/orgs/#{org_name}/public_members/#{member_name}", params)
    end
    alias :make_public :publicize
    alias :publicize_membership :publicize

    # Conceal a user’s membership
    #
    # = Examples
    #  github = Github.new :oauth_token => '...'
    #  github.orgs.members.conceal 'org-name', 'member-name'
    #
    def conceal(org_name, member_name, params={})
      assert_presence_of org_name, member_name
      normalize! params
      delete_request("/orgs/#{org_name}/public_members/#{member_name}", params)
    end
    alias :conceal_membership :conceal

  end # Orgs::Members
end # Github
