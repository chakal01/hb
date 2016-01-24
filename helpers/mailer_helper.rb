require 'yaml'
require 'mail'

config_mail, mailer = YAML.load_file('./config/mailer.yml'), {}
config_mail.each{|k,v| mailer[k.to_sym] = v}
Mail.defaults do
  delivery_method :smtp,  mailer
end

#
# helper module to send mail
#
module MailerHelper

  def send_mail(email, title, content)
    config = YAML.load_file("./config/application.yml")
    begin
      mail = Mail.new do
        from config["email"]["from"]
        to config["email"]["to"].join(";")
        subject config["email"]["subject"]
        body "Salut ! Un formulaire de contact a été rempli sur http://hb.fr !\n\n\nPar: #{email}\nObjet: #{title}\n\n#{content}"
      end
      mail.deliver
    rescue => e
      File.open('log/mailer.log', 'a+') do |f|
        f.write "[#{Time.now}] #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end

end