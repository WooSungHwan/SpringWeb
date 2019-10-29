package org.zerock.controller;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.zerock.domain.BoardAttachVO;
import org.zerock.domain.BoardVO;
import org.zerock.domain.Criteria;
import org.zerock.domain.PageDTO;
import org.zerock.service.BoardService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@RequestMapping("/board/*")
@AllArgsConstructor
public class BoardController {
	
	private BoardService service;
	
	@GetMapping("/list")
	public void list(@ModelAttribute("cri") Criteria cri, Model model) {
		log.info("list : "+cri);
		
		int total = service.getTotal(cri);
		log.info("total : "+total);
		
		model.addAttribute("list",service.getList(cri));
		model.addAttribute("pageMaker", new PageDTO(cri,total));
		//model.addAttribute("pageMaker",new PageDTO(cri,50));
	}
	
	@GetMapping("/register")
	@PreAuthorize("isAuthenticated()")	
	public void register() {
		
	}
	
	@PostMapping("/register")
	@PreAuthorize("isAuthenticated()")
	public String register(BoardVO board, RedirectAttributes rttr) {//등록 후 이동필요
		log.info("==========================");
		log.info("register : "+board);
		
		if(board.getAttachList() != null) {
			board.getAttachList().forEach(attach -> log.info(attach));
		}
		
		log.info("==========================");
		
		service.register(board);
		rttr.addFlashAttribute("result",board.getBno()); //리다이렉트 페이지에 result 전달.
		return "redirect:/board/list";
	}
	
	@GetMapping({"/get", "/modify"})
	public void get(@RequestParam("bno") Long bno, @ModelAttribute("cri") Criteria cri , Model model) {
		log.info("/get or /modify");
		model.addAttribute("board",service.get(bno));
	}
	
	@PreAuthorize("principal.username == #board.writer")
	@PostMapping("/modify")
	public String modify(BoardVO board, @ModelAttribute("cri") Criteria cri, RedirectAttributes rttr) {//수정 후 이동필요
		log.info("modify : "+board);
		if(service.modify(board)) {
			rttr.addFlashAttribute("result","success");
		}
		
		rttr.addAttribute("pageNum", cri.getPageNum());
		rttr.addAttribute("amount", cri.getAmount());
		
		return "redirect:/board/list"+cri.getListLink();
	}
	
	@PreAuthorize("principal.username == #writer")
	@PostMapping("/remove")
	public String remove(@RequestParam("bno") Long bno, Criteria cri, RedirectAttributes rttr, String writer) { //삭제후 이동필요
		log.info("remove....."+bno);
		
		//삭제전 첨부파일 목록 확보
		List<BoardAttachVO> attachList = service.getAttachList(bno);
		
		if(service.remove(bno)) { // 여기서 tbl_board, tbl_attach 같이 삭제됨.
			//delete Attach Files
			deleteFiles(attachList);
			
			rttr.addFlashAttribute("result","success");
		}
		return "redirect:/board/list"+cri.getListLink();
	}
	
	@GetMapping(value = "/getAttachList",
			produces=MediaType.APPLICATION_JSON_UTF8_VALUE)
	@ResponseBody
	public ResponseEntity<List<BoardAttachVO>> getAttachList(Long bno){
		log.info("getAttachList "+bno);
		
		//@RestController가 아니면 @ResponseBody를 써야함.
		return new ResponseEntity<>(service.getAttachList(bno), HttpStatus.OK); //List로 반환받은 것을 ResponseEntity가 JSON으로 변환함.
	}
	
	private void deleteFiles(List<BoardAttachVO> attachList) {
		if(attachList == null || attachList.size() == 0) {
			return;
		}
		log.info("delete attach files.................");
		log.info(attachList);
		
		attachList.forEach(attach ->{
			
			try {
				String commonPath = "C:\\upload\\"+attach.getUploadPath()+"\\";
				Path file = Paths.get(commonPath+attach.getUuid()+"_"+attach.getFileName());
				
				Files.deleteIfExists(file);
				
				if(Files.probeContentType(file).startsWith("image")) {
					Path thumbnail = Paths.get(commonPath+"s_"+attach.getUuid()+"_"+attach.getFileName());
					
					Files.delete(thumbnail);
				}

			}catch(Exception e) {
				log.error("delete file error"+e.getMessage());
			}
			
		});
		
	}
	
}
