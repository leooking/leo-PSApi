# frozen_string_literal: true

class FolderService

  def initialize(args)
    @user                     = args[:user]
    @object                   = args[:object]                   ||= nil  
    @type                     = @object                         ? @object.class.name.downcase : nil
    @source_folder            = args[:source_folder]            ||= nil
    @parent_folder            = args[:parent_folder]            ||= nil
    @destination_folder       = args[:destination_folder]       ||= nil
    @destination_folder_name  = args[:destination_folder_name]  ||= nil
    @parent_id                = !@parent_folder.nil?            ? @parent_folder.id : nil
  end

  def create_new_location
    remove_from_source_folder if @source_folder
    create_folder
    install_object
    @folder
  end

  # to a new home or make it an orphan
  def relocate_object
    remove_from_source_folder if @source_folder
    add_to_destination_folder if @destination_folder
  end

  private

    def remove_from_source_folder
      case @type
      when 'resource'
        @source_folder.resources.delete @object
      when 'asset'
        @source_folder.assets.delete    @object
      when 'project'
        @source_folder.projects.delete  @object
      when 'folder'
        @object.update(parent_id: nil)
      end
    end

    def add_to_destination_folder
      case @type
      when 'resource'
        @destination_folder.resources << @object
      when 'asset'
        @destination_folder.assets << @object
      when 'project'
        @destination_folder.projects << @object
      when 'folder'
        @object.update(parent_id: @destination_folder.id)
      end
    end

    def create_folder
      @folder = Folder.create(
        name: @destination_folder_name, 
        folder_type: @type, 
        scope: @object.scope, 
        user_id: @user.id, 
        org_id: @user.org.id,
        parent_id: @parent_id
      )
    end

    def install_object
      case @type
      when 'resource'
        @folder.resources << @object
      when 'asset'
        @folder.assets << @object
      when 'project'
        @folder.projects << @object
      end
    end
    
end