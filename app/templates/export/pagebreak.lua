-- Pandoc filter: convert \newpage to OOXML page breaks for DOCX output
function RawBlock(el)
  if el.text:match("\\newpage") then
    return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
  end
end
