class ApplicationMailer < ActionMailer::Base
  default from: "user@realdomain.com" # 本番環境でメール送信する場合は、自分が使っているメアドに変更すること
  layout "mailer"
end
