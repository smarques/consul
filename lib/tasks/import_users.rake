require 'csv'    

namespace :vcv do
  desc "Import vcv users from users.csv"

  task :import_users=> [:environment] do 
    path = './users.csv'
    if(!File.exist?(path))
      raise 'File not found: ./users.csv (a classic msg for a classic error)'
    end
    csv_text = File.read(path)
    csv = CSV.parse(csv_text, :headers => true)
   
    csv.each do |row|
      if( !(row["APPELLO"] && Integer(row["APPELLO"])>0) ) then next end
      email = row["E-Mail"]
      email.strip!
      exists = User.find_by(email: email)
      if(!exists)
        newpass = Array.new(16){[*"A".."Z", *"0".."9"].sample}.join
        username = email.split('@').first[0..25].gsub(/[^a-zA-Z.0-9]/, '')
        user = User.create!(username: username, email: email, password: newpass,
        password_confirmation: newpass, confirmed_at: Time.current,
        terms_of_service: "1")
        puts "Importing #{email}"
        Mailer.user_imported_notice(
          user,
            "Benvenuto ad assemblea@venetochevogliamo",
          newpass
        ).deliver_now
      end
    end
  end
end