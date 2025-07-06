module Parents::ChildrenHelper
  def human_payment_method(method)
    {
      "cash" => "Espèces",
      "cheque" => "Chèque",
      "virement" => "Virement",
      "pass" => "Pass",
      "hello_asso" => "Hello Asso",
      "offert" => "Offert",
      "offert_next_year" => "Offert Fin D'année",
      "financed" => "Financé",
    }[method.to_s] || method.to_s.humanize
  end
end
