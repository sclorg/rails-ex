class PagesController < ApplicationController
  def index
    #@pics1 = %w[ pic1-1.jpg pic1-2.jpg pic1-3.jpg pic1-4.jpg]
    @pics1 = {
      "pic1-1.jpg" => "Entreprises",
      "pic1-2.jpg" => "Projet le plus abouti",
      "pic1-3.jpg" => "Les moyens de transport (révolution ou existants)",
      "pic1-4.jpg" => "La chronologie théorique du projet"
    }

    @pics2 = %w[ pic1-1.jpg pic1-2.jpg pic1-3.jpg pic1-4.jpg ]

  end
end
