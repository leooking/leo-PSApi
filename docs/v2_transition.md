**Notes:**

- Three equal nouns
  - Scopable
    - User, group, org
  - Searchable
  - Resources & Assets attach / detach from Project
- Generators
- Side nav drawer
  - Default hidden
  - Collapsable sections
- Dashboard
- Customer admin
- _Since we’re jail-breaking assets out from their project, and allowing the attaching of assets to projects (just like resources) I think the project subnav can pretty much go away._

**Has many thorough join models:**

- asset_org
- asset_group
- group_resource
- group_project
- org_resource
- project_org

- asset_user
- project_user
- resource_user

- model relations
  - user.assets (.projects, .resources)
  - group.assets (.projects, .resources)
  - org.assets (.projects, .resources)

**Etcetera:**

- Add scope to projects, default org
- Change asset default scope to org
- Replacing some belongs_to and foreign keys
- Updating payloads
- Updating admin
