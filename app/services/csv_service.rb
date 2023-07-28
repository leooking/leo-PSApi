# frozen_string_literal: true

# CSV file parser and processor
class CsvService

  COLUMNS = [:org_pid, :group_pid, :fname, :lname, :email]

  def initialize(args)
    @logger = Logger.new($stdout)
    # We expect UTF-8 and remove BOM header if present. 
    @file_name = args[:tempfile].original_filename
    @csv_hash = nil
    File.open(args[:tempfile], 'r:bom|utf-8') { |f| @csv_hash = SmarterCSV.process(f) }
  end

  def provision_users
    do_user_provisioning if validate_csv
  end

  def provision_states
    do_state_provisioning
  end

  def provision_customer_users(org_pid, group_pid)
    org = Org.find_by(pid: org_pid)
    group = Group.find_by(pid: group_pid)
    return unless org && group

    do_user_provisioning(org, group)
  end

  private

  # validate the csv and send email in case of failure
  # for any empty values or in case of group or org is non-existent, also if user is duplicated
  def validate_csv
    failed_records = {}
    @csv_hash.each_with_index do |hash, index|
      errors = []
      org = nil
      COLUMNS.each do |attr|
        key = hash[attr]
        errors.append("field '#{attr}' is empty") if key.nil?
        if key.present?
          if attr == :org_pid
            org = Org.find_by(pid: hash[:org_pid])
            errors.append("Org not found") if org.nil?
          end
          if attr == :group_pid
            grp = Group.find_by(pid: hash[:group_pid], org: org)
            errors.append("Group not found for the organisation") if grp.nil?
          end
          if attr == :email
            u = User.find_by(email: hash[:email].downcase)
            errors.append("User already exists") if u.present?
          end
        end
      end
      failed_records[index] = errors if errors.present?
    end
    UserMailer.with(file_name: @file_name, records: failed_records).failed_records_notification.deliver_now if failed_records.present?
    failed_records.empty?
  end

  def do_user_provisioning(org = nil, group = nil)
      users = 0
      @csv_hash.each do |h|
        o = org || Org.find_by(pid: h[:org_pid])
        g = group || Group.find_by(pid: h[:group_pid])
        u = User.create(org_id: o.id, group_id: g.id, fname: h[:fname], lname: h[:lname], email: h[:email].downcase)
        o.users << u
        # g.members << u
        u.activate_in_group(g)
        users += 1
      end
      users
    end

    def do_state_provisioning
      states = 0
      @csv_hash.each do |row|
        state = State.find_or_create_by(name: row[:state])
        state.update(abbreviation: row[:abbreviation], homepage: row[:state_homepage], procurement: row[:procurement_website_url])
        states += 1
        state.state_agencies.destroy_all

        if row[:department_of_transportation].present?
          StateAgency.create(name: "Department of Transportation", url: row[:department_of_transportation], state: state)
        end

        if row[:department_of_education].present?
          StateAgency.create(name: "Department of Education", url: row[:department_of_education], state: state)
        end

        if row[:department_of_healthcare].present?
          StateAgency.create(name: "Department of Healthcare", url: row[:department_of_healthcare], state: state)
        end

        if row[:department_of_public_safety].present?
          StateAgency.create(name: "Department of Public Safety", url: row[:department_of_public_safety], state: state)
        end

        if row[:department_of_social_services].present?
          StateAgency.create(name: "Department of Transportation", url: row[:department_of_social_services], state: state)
        end

        if row[:capital_improvement_plan].present?
          StateAgency.create(name: "Capital Improvement Plan", url: row[:capital_improvement_plan], state: state)
        end
      end
      
      return states
    end
end
