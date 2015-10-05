module Fastlane
  class SetupAndroid < Setup
    def run
      if FastlaneFolder.setup? and !Helper.is_test?
        Helper.log.info "Fastlane already set up at path #{folder}".yellow
        return
      end

      response = agree('Do you have everything commited in version control? If not please do so now! (y/n)'.yellow, true)
      return unless response

      FastlaneFolder.create_folder! unless Helper.is_test?
      FileUtils.mkdir(File.join(folder, 'actions')) unless File.directory?(File.join(folder, 'actions'))
      generate_appfile
      generate_fastfile
      show_analytics
      Helper.log.info ""
      Helper.log.info "If you want to upload app metadata and builds to Google Play".green
      Helper.log.info "run `supply init`".green
      Helper.log.info 'Successfully finished setting up fastlane'.green
    end
    
    def generate_appfile
      Helper.log.info '------------------------------'
      Helper.log.info 'To not re-enter your packagename and issuer every time you run one of the fastlane tools or fastlane, these will be stored in a so-called Appfile.'.green

      package_name = ask('Package Name (com.krausefx.app): '.yellow)
      puts ""
      puts "Follow the Setup Guide on how to get the Issuer: https://github.com/fastlane/supply#setup".yellow
      puts "The issuer email looks like this: 137123276006-aaaeltp0aqgn2opfb7tk46ovaaa3hv1g@developer.gserviceaccount.com".yellow
      issuer = ask('Issuer: '.yellow)
      keyfile = ask('Path to the key file: '.yellow)

      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/AppfileTemplateAndroid")
      template.gsub!('[[ISSUER]]', issuer)
      template.gsub!('[[KEYFILE]]', keyfile)
      template.gsub!('[[PACKAGE_NAME]]', package_name)
      path = File.join(folder, 'Appfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your preferred app metadata information.".green
    end

    def generate_fastfile
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/FastfileTemplateAndroid")

      template.gsub!('[[FASTLANE_VERSION]]', Fastlane::VERSION)

      path = File.join(folder, 'Fastfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your own deployment lanes.".green
    end

    def folder
      FastlaneFolder.path
    end
  end
end
